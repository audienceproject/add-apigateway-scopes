#!/bin/bash
# Create the Python script which will update DynamoDB
cat > $WERCKER_SOURCE_DIR/import.py <<EOL
import json
import sys
import re
import boto3

from boto3.dynamodb.conditions import Key, Attr

mappings = json.loads(sys.stdin.read())
awsAccountId = sys.argv[1]
apiGatewayRegion = sys.argv[2]
apiGatewayId = sys.argv[3]
apiGatewayStage = sys.argv[4]
dynamo_tablename = sys.argv[5]

dynamodb = boto3.resource('dynamodb', region_name=apiGatewayRegion)
table = dynamodb.Table(dynamo_tablename)

existingRules = table.query(
    KeyConditionExpression=Key('apiId').eq(apiGatewayId)
)['Items']

with table.batch_writer() as batch:
    for existingRule in existingRules:
        batch.delete_item(
            Key={
                'apiId': existingRule["apiId"],
                'methodArn': existingRule["methodArn"]
            }
        )

for mapping in mappings:
    for method in mappings[mapping]:
        if ( mappings[mapping].get(method) ):
            print ("arn:aws:execute-api:" + apiGatewayRegion + ":" + awsAccountId + ":" + apiGatewayId + "/" + apiGatewayStage + "/" + method + re.sub("{.+}", "*", mapping) + " => " + ",".join(mappings[mapping][method]))
            table.put_item(
               Item={
                    'apiId': apiGatewayId,
                    'methodArn': "arn:aws:execute-api:" + apiGatewayRegion + ":" + awsAccountId + ":" + apiGatewayId + "/" + apiGatewayStage + "/" + method + re.sub("{.+}", "*", mapping),
                    'scopes': set(mappings[mapping][method])
                }
            )
EOL
# Parse the swagger file for the scope rules and add them to DynamoDB
cat $WERCKER_ADD_SCOPES_SWAGGER_FILE | jq '.paths | map_values( . | map_values(.["x-route-scopes"]))' | python3 import.py \
$WERCKER_ADD_SCOPES_AWS_ACCOUNT_ID \
$WERCKER_ADD_SCOPES_API_GATEWAY_REGION \
$WERCKER_ADD_SCOPES_API_GATEWAY_ID \
$WERCKER_ADD_SCOPES_API_GATEWAY_STAGE \
$WERCKER_ADD_SCOPES_DYNAMO_TABLENAME
