# Add Scopes

A Wercker step that updates a database with scope rules for an API Gateway instance.

*Fair warning*: This step provides limited value outside the very specialized scope that it was conceived in.

The step is parameterized as follows:

* *swagger-file*: relative path to a Swagger document with [x-route-scopes] annotations.
* *aws_account_id*: an AWS account ID
* *api_gateway_region*: the region where the API Gateway instance is located (e.g. `us-east-1`)
* *api_gateway_id*: the ID of the API Gateway instance (e.g. `kbh4evafj0b5`)
* *api_gateway_stage*: the stage of the API Gateway instance (e.g. `dev`)
* *oauth_dynamo_tablename*: the DynamoDB table that stores the OAuth scope mappings
* *oauth_dynamo_region*: location of the DynamoDB table (e.g. `us-east-1`)

## Example

```
steps:
    - audienceproject/add-scopes:
        - swagger_file: api.json
        - aws_account_id: someAwsAccountId
        - api_gateway_region: us-east-1
        - api_gateway_id: someApiGatewayID
        - api_gateway_stage: dev
        - oauth_dynamo_tablename: someTableName
        - oauth_dynamo_region: us-east-1
```
