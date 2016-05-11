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

Swagger example (notice "security", "x-route-scopes" and "securityDefinitions" keys):

```
{
  "swagger": "2.0",
  "info": {
    "version": "2016-05-11T11:42:25Z",
    "title": "foo"
  },
  "host": "4lw61t4wwl.execute-api.us-east-1.amazonaws.com",
  "basePath": "/dev",
  "schemes": [
    "https"
  ],
  "paths": {
    "/": {
      "get": {
        "consumes": [
          "application/json"
        ],
        "produces": [
          "application/json"
        ],
        "responses": {
          "200": {
            "description": "200 response",
            "schema": {
              "$ref": "#/definitions/Empty"
            }
          }
        },
        "security" : [ {
          "oauth" : [ ]
        } ],
        "x-route-scopes" : [ "scope1", "scope2" ],
        "x-amazon-apigateway-integration": {
          "responses": {
            "default": {
              "statusCode": "200"
            }
          },
          "passthroughBehavior": "when_no_match",
          "requestTemplates": {
            "application/json": "{\"statusCode\": 200}"
          },
          "type": "mock"
        }
      }
    }
  },
  "securityDefinitions" : {
    "oauth" : {
      "type" : "apiKey",
      "name" : "Auth",
      "in" : "header",
      "x-amazon-apigateway-authtype" : "custom",
      "x-amazon-apigateway-authorizer" : {
        "authorizerCredentials" : "arn:aws:iam::${ACCOUNT_ID}:role/ExecuteLambdaFunctions",
        "authorizerResultTtlInSeconds" : 0,
        "identityValidationExpression" : "^Bearer .*$",
        "authorizerUri" : "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${ACCOUNT_ID}:function:oauth-tokenValidator/invocations",
        "type" : "token"
      }
    }
  },
  "definitions": {
    "Empty": {
      "type": "object"
    }
  }
}
```

Step example

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
