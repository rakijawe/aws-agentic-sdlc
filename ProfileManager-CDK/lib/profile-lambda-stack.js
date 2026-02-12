"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProfileLambdaStack = void 0;
const cdk = require("aws-cdk-lib");
const lambda = require("aws-cdk-lib/aws-lambda");
const apigateway = require("aws-cdk-lib/aws-apigateway");
const ec2 = require("aws-cdk-lib/aws-ec2");
const secretsmanager = require("aws-cdk-lib/aws-secretsmanager");
/**
 * CDK Stack for Profile Management Lambda Functions and API Gateway
 * Requirements: Req 15-25 (Profile Management)
 * Phase: 7 - Testing & Deployment
 */
class ProfileLambdaStack extends cdk.Stack {
    constructor(scope, id, props) {
        super(scope, id, props);
        // Import existing VPC (or create new one)
        const vpc = ec2.Vpc.fromLookup(this, 'VPC', {
            isDefault: true
        });
        // Import existing database secret
        const dbSecret = secretsmanager.Secret.fromSecretNameV2(this, 'DBSecret', 'profilemanager/db-credentials');
        // Lambda execution role with necessary permissions
        const lambdaRole = new cdk.aws_iam.Role(this, 'ProfileLambdaRole', {
            assumedBy: new cdk.aws_iam.ServicePrincipal('lambda.amazonaws.com'),
            managedPolicies: [
                cdk.aws_iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaVPCAccessExecutionRole'),
                cdk.aws_iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole')
            ]
        });
        // Grant secret read permissions
        dbSecret.grantRead(lambdaRole);
        // Common Lambda environment variables
        const commonEnvironment = {
            DB_URL: dbSecret.secretValueFromJson('url').unsafeUnwrap(),
            DB_USER: dbSecret.secretValueFromJson('username').unsafeUnwrap(),
            DB_PASSWORD: dbSecret.secretValueFromJson('password').unsafeUnwrap(),
            EMAIL_MODIFICATION_ALLOWED: 'true'
        };
        // Lambda Layer for shared dependencies (Jackson, PostgreSQL driver, SLF4J)
        const sharedLayer = new lambda.LayerVersion(this, 'SharedDependenciesLayer', {
            code: lambda.Code.fromAsset('../ProfileManager-API/target/lambda-layer'),
            compatibleRuntimes: [lambda.Runtime.JAVA_17],
            description: 'Shared dependencies for profile management Lambda functions'
        });
        // GetProfileHandler Lambda Function
        const getProfileHandler = new lambda.Function(this, 'GetProfileHandler', {
            runtime: lambda.Runtime.JAVA_17,
            handler: 'com.myorg.usermanagement.handler.GetProfileHandler::handleRequest',
            code: lambda.Code.fromAsset('../ProfileManager-API/target/ProfileManager-API-1.0.0.jar'),
            memorySize: 512,
            timeout: cdk.Duration.seconds(30),
            environment: commonEnvironment,
            vpc: vpc,
            vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS },
            role: lambdaRole,
            layers: [sharedLayer],
            description: 'Retrieves user profile data (Req 15, 16)'
        });
        // UpdateProfileHandler Lambda Function
        const updateProfileHandler = new lambda.Function(this, 'UpdateProfileHandler', {
            runtime: lambda.Runtime.JAVA_17,
            handler: 'com.myorg.usermanagement.handler.UpdateProfileHandler::handleRequest',
            code: lambda.Code.fromAsset('../ProfileManager-API/target/ProfileManager-API-1.0.0.jar'),
            memorySize: 512,
            timeout: cdk.Duration.seconds(30),
            environment: commonEnvironment,
            vpc: vpc,
            vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS },
            role: lambdaRole,
            layers: [sharedLayer],
            description: 'Updates user profile data with validation (Req 17-23)'
        });
        // GetEmailPolicyHandler Lambda Function
        const getEmailPolicyHandler = new lambda.Function(this, 'GetEmailPolicyHandler', {
            runtime: lambda.Runtime.JAVA_17,
            handler: 'com.myorg.usermanagement.handler.GetEmailPolicyHandler::handleRequest',
            code: lambda.Code.fromAsset('../ProfileManager-API/target/ProfileManager-API-1.0.0.jar'),
            memorySize: 256,
            timeout: cdk.Duration.seconds(10),
            environment: commonEnvironment,
            role: lambdaRole,
            layers: [sharedLayer],
            description: 'Returns email modification policy (Req 25)'
        });
        // API Gateway REST API
        const api = new apigateway.RestApi(this, 'ProfileManagementAPI', {
            restApiName: 'Profile Management API',
            description: 'API for user profile management',
            deployOptions: {
                stageName: 'prod',
                throttlingRateLimit: 100,
                throttlingBurstLimit: 200,
                loggingLevel: apigateway.MethodLoggingLevel.INFO,
                dataTraceEnabled: true,
                metricsEnabled: true
            },
            defaultCorsPreflightOptions: {
                allowOrigins: apigateway.Cors.ALL_ORIGINS,
                allowMethods: apigateway.Cors.ALL_METHODS,
                allowHeaders: ['Content-Type', 'Authorization']
            }
        });
        // JWT Authorizer (placeholder - implement with Cognito or custom authorizer)
        // const authorizer = new apigateway.TokenAuthorizer(this, 'JWTAuthorizer', {
        //   handler: jwtAuthorizerFunction,
        //   identitySource: 'method.request.header.Authorization'
        // });
        // /profile resource
        const profileResource = api.root.addResource('profile');
        // GET /profile - Retrieve profile
        profileResource.addMethod('GET', new apigateway.LambdaIntegration(getProfileHandler, {
            proxy: true,
            integrationResponses: [
                {
                    statusCode: '200',
                    responseParameters: {
                        'method.response.header.Access-Control-Allow-Origin': "'*'"
                    }
                }
            ]
        }), {
            // authorizer: authorizer,  // Enable in production
            methodResponses: [
                {
                    statusCode: '200',
                    responseParameters: {
                        'method.response.header.Access-Control-Allow-Origin': true
                    }
                }
            ]
        });
        // PUT /profile - Update profile
        profileResource.addMethod('PUT', new apigateway.LambdaIntegration(updateProfileHandler, {
            proxy: true,
            integrationResponses: [
                {
                    statusCode: '200',
                    responseParameters: {
                        'method.response.header.Access-Control-Allow-Origin': "'*'"
                    }
                }
            ]
        }), {
            // authorizer: authorizer,  // Enable in production
            methodResponses: [
                {
                    statusCode: '200',
                    responseParameters: {
                        'method.response.header.Access-Control-Allow-Origin': true
                    }
                }
            ]
        });
        // /profile/email-policy resource
        const emailPolicyResource = profileResource.addResource('email-policy');
        // GET /profile/email-policy - Get email modification policy
        emailPolicyResource.addMethod('GET', new apigateway.LambdaIntegration(getEmailPolicyHandler, {
            proxy: true,
            integrationResponses: [
                {
                    statusCode: '200',
                    responseParameters: {
                        'method.response.header.Access-Control-Allow-Origin': "'*'"
                    }
                }
            ]
        }), {
            // authorizer: authorizer,  // Enable in production
            methodResponses: [
                {
                    statusCode: '200',
                    responseParameters: {
                        'method.response.header.Access-Control-Allow-Origin': true
                    }
                }
            ]
        });
        // CloudWatch Log Group for API Gateway
        new cdk.aws_logs.LogGroup(this, 'APIGatewayLogGroup', {
            logGroupName: `/aws/apigateway/${api.restApiName}`,
            retention: cdk.aws_logs.RetentionDays.ONE_MONTH,
            removalPolicy: cdk.RemovalPolicy.DESTROY
        });
        // Outputs
        new cdk.CfnOutput(this, 'APIEndpoint', {
            value: api.url,
            description: 'API Gateway endpoint URL'
        });
        new cdk.CfnOutput(this, 'GetProfileFunctionArn', {
            value: getProfileHandler.functionArn,
            description: 'GetProfileHandler Lambda ARN'
        });
        new cdk.CfnOutput(this, 'UpdateProfileFunctionArn', {
            value: updateProfileHandler.functionArn,
            description: 'UpdateProfileHandler Lambda ARN'
        });
        new cdk.CfnOutput(this, 'GetEmailPolicyFunctionArn', {
            value: getEmailPolicyHandler.functionArn,
            description: 'GetEmailPolicyHandler Lambda ARN'
        });
    }
}
exports.ProfileLambdaStack = ProfileLambdaStack;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoicHJvZmlsZS1sYW1iZGEtc3RhY2suanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJwcm9maWxlLWxhbWJkYS1zdGFjay50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOzs7QUFBQSxtQ0FBbUM7QUFDbkMsaURBQWlEO0FBQ2pELHlEQUF5RDtBQUN6RCwyQ0FBMkM7QUFFM0MsaUVBQWlFO0FBR2pFOzs7O0dBSUc7QUFDSCxNQUFhLGtCQUFtQixTQUFRLEdBQUcsQ0FBQyxLQUFLO0lBQy9DLFlBQVksS0FBZ0IsRUFBRSxFQUFVLEVBQUUsS0FBc0I7UUFDOUQsS0FBSyxDQUFDLEtBQUssRUFBRSxFQUFFLEVBQUUsS0FBSyxDQUFDLENBQUM7UUFFeEIsMENBQTBDO1FBQzFDLE1BQU0sR0FBRyxHQUFHLEdBQUcsQ0FBQyxHQUFHLENBQUMsVUFBVSxDQUFDLElBQUksRUFBRSxLQUFLLEVBQUU7WUFDMUMsU0FBUyxFQUFFLElBQUk7U0FDaEIsQ0FBQyxDQUFDO1FBRUgsa0NBQWtDO1FBQ2xDLE1BQU0sUUFBUSxHQUFHLGNBQWMsQ0FBQyxNQUFNLENBQUMsZ0JBQWdCLENBQ3JELElBQUksRUFDSixVQUFVLEVBQ1YsK0JBQStCLENBQ2hDLENBQUM7UUFFRixtREFBbUQ7UUFDbkQsTUFBTSxVQUFVLEdBQUcsSUFBSSxHQUFHLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxJQUFJLEVBQUUsbUJBQW1CLEVBQUU7WUFDakUsU0FBUyxFQUFFLElBQUksR0FBRyxDQUFDLE9BQU8sQ0FBQyxnQkFBZ0IsQ0FBQyxzQkFBc0IsQ0FBQztZQUNuRSxlQUFlLEVBQUU7Z0JBQ2YsR0FBRyxDQUFDLE9BQU8sQ0FBQyxhQUFhLENBQUMsd0JBQXdCLENBQUMsOENBQThDLENBQUM7Z0JBQ2xHLEdBQUcsQ0FBQyxPQUFPLENBQUMsYUFBYSxDQUFDLHdCQUF3QixDQUFDLDBDQUEwQyxDQUFDO2FBQy9GO1NBQ0YsQ0FBQyxDQUFDO1FBRUgsZ0NBQWdDO1FBQ2hDLFFBQVEsQ0FBQyxTQUFT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aUJBQ0Y7YUFDRjtTQUNGLENBQ0YsQ0FBQztRQUVGLHVDQUF1QztRQUN2QyxJQUFJLEdBQUcsQ0FBQyxRQUFRLENBQUMsUUFBUSxDQUFDLElBQUksRUFBRSxvQkFBb0IsRUFBRTtZQUNwRCxZQUFZLEVBQUUsbUJBQW1CLEdBQUcsQ0FBQyxXQUFXLEVBQUU7WUFDbEQsU0FBUyxFQUFFLEdBQUcsQ0FBQyxRQUFRLENBQUMsYUFBYSxDQUFDLFNBQVM7WUFDL0MsYUFBYSxFQUFFLEdBQUcsQ0FBQyxhQUFhLENBQUMsT0FBTztTQUN6QyxDQUFDLENBQUM7UUFFSCxVQUFVO1FBQ1YsSUFBSSxHQUFHLENBQUMsU0FBUyxDQUFDLElBQUksRUFBRSxhQUFhLEVBQUU7WUFDckMsS0FBSyxFQUFFLEdBQUcsQ0FBQyxHQUFHO1lBQ2QsV0FBVyxFQUFFLDBCQUEwQjtTQUN4QyxDQUFDLENBQUM7UUFFSCxJQUFJLEdBQUcsQ0FBQyxTQUFTLENBQUMsSUFBSSxFQUFFLHVCQUF1QixFQUFFO1lBQy9DLEtBQUssRUFBRSxpQkFBaUIsQ0FBQyxXQUFXO1lBQ3BDLFdBQVcsRUFBRSw4QkFBOEI7U0FDNUMsQ0FBQyxDQUFDO1FBRUgsSUFBSSxHQUFHLENBQUMsU0FBUyxDQUFDLElBQUksRUFBRSwwQkFBMEIsRUFBRTtZQUNsRCxLQUFLLEVBQUUsb0JBQW9CLENBQUMsV0FBVztZQUN2QyxXQUFXLEVBQUUsaUNBQWlDO1NBQy9DLENBQUMsQ0FBQztRQUVILElBQUksR0FBRyxDQUFDLFNBQVMsQ0FBQyxJQUFJLEVBQUUsMkJBQTJCLEVBQUU7WUFDbkQsS0FBSyxFQUFFLHFCQUFxQixDQUFDLFdBQVc7WUFDeEMsV0FBVyxFQUFFLGtDQUFrQztTQUNoRCxDQUFDLENBQUM7SUFDTCxDQUFDO0NBQ0Y7QUFsT0QsZ0RBa09DIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0ICogYXMgY2RrIGZyb20gJ2F3cy1jZGstbGliJztcclxuaW1wb3J0ICogYXMgbGFtYmRhIGZyb20gJ2F3cy1jZGstbGliL2F3cy1sYW1iZGEnO1xyXG5pbXBvcnQgKiBhcyBhcGlnYXRld2F5IGZyb20gJ2F3cy1jZGstbGliL2F3cy1hcGlnYXRld2F5JztcclxuaW1wb3J0ICogYXMgZWMyIGZyb20gJ2F3cy1jZGstbGliL2F3cy1lYzInO1xyXG5pbXBvcnQgKiBhcyByZHMgZnJvbSAnYXdzLWNkay1saWIvYXdzLXJkcyc7XHJcbmltcG9ydCAqIGFzIHNlY3JldHNtYW5hZ2VyIGZyb20gJ2F3cy1jZGstbGliL2F3cy1zZWNyZXRzbWFuYWdlcic7XHJcbmltcG9ydCB7IENvbnN0cnVjdCB9IGZyb20gJ2NvbnN0cnVjdHMnO1xyXG5cclxuLyoqXHJcbiAqIENESyBTdGFjayBmb3IgUHJvZmlsZSBNYW5hZ2VtZW50IExhbWJkYSBGdW5jdGlvbnMgYW5kIEFQSSBHYXRld2F5XHJcbiAqIFJlcXVpcmVtZW50czogUmVxIDE1LTI1IChQcm9maWxlIE1hbmFnZW1lbnQpXHJcbiAqIFBoYXNlOiA3IC0gVGVzdGluZyAmIERlcGxveW1lbnRcclxuICovXHJcbmV4cG9ydCBjbGFzcyBQcm9maWxlTGFtYmRhU3RhY2sgZXh0ZW5kcyBjZGsuU3RhY2sge1xyXG4gIGNvbnN0cnVjdG9yKHNjb3BlOiBDb25zdHJ1Y3QsIGlkOiBzdHJpbmcsIHByb3BzPzogY2RrLlN0YWNrUHJvcHMpIHtcclxuICAgIHN1cGVyKHNjb3BlLCBpZCwgcHJvcHMpO1xyXG5cclxuICAgIC8vIEltcG9ydCBleGlzdGluZyBWUEMgKG9yIGNyZWF0ZSBuZXcgb25lKVxyXG4gICAgY29uc3QgdnBjID0gZWMyLlZwYy5mcm9tTG9va3VwKHRoaXMsICdWUEMnLCB7XHJcbiAgICAgIGlzRGVmYXVsdDogdHJ1ZVxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gSW1wb3J0IGV4aXN0aW5nIGRhdGFiYXNlIHNlY3JldFxyXG4gICAgY29uc3QgZGJTZWNyZXQgPSBzZWNyZXRzbWFuYWdlci5TZWNyZXQuZnJvbVNlY3JldE5hbWVWMihcclxuICAgICAgdGhpcyxcclxuICAgICAgJ0RCU2VjcmV0JyxcclxuICAgICAgJ3Byb2ZpbGVtYW5hZ2VyL2RiLWNyZWRlbnRpYWxzJ1xyXG4gICAgKTtcclxuXHJcbiAgICAvLyBMYW1iZGEgZXhlY3V0aW9uIHJvbGUgd2l0aCBuZWNlc3NhcnkgcGVybWlzc2lvbnNcclxuICAgIGNvbnN0IGxhbWJkYVJvbGUgPSBuZXcgY2RrLmF3c19pYW0uUm9sZSh0aGlzLCAnUHJvZmlsZUxhbWJkYVJvbGUnLCB7XHJcbiAgICAgIGFzc3VtZWRCeTogbmV3IGNkay5hd3NfaWFtLlNlcnZpY2VQcmluY2lwYWwoJ2xhbWJkYS5hbWF6b25hd3MuY29tJyksXHJcbiAgICAgIG1hbmFnZWRQb2xpY2llczogW1xyXG4gICAgICAgIGNkay5hd3NfaWFtLk1hbmFnZWRQb2xpY3kuZnJvbUF3c01hbmFnZWRQb2xpY3lOYW1lKCdzZXJ2aWNlLXJvbGUvQVdTTGFtYmRhVlBDQWNjZXNzRXhlY3V0aW9uUm9sZScpLFxyXG4gICAgICAgIGNkay5hd3NfaWFtLk1hbmFnZWRQb2xpY3kuZnJvbUF3c01hbmFnZWRQb2xpY3lOYW1lKCdzZXJ2aWNlLXJvbGUvQVdTTGFtYmRhQmFzaWNFeGVjdXRpb25Sb2xlJylcclxuICAgICAgXVxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gR3JhbnQgc2VjcmV0IHJlYWQgcGVybWlzc2lvbnNcclxuICAgIGRiU2VjcmV0LmdyYW50UmVhZChsYW1iZGFSb2xlKTtcclxuXHJcbiAgICAvLyBDb21tb24gTGFtYmRhIGVudmlyb25tZW50IHZhcmlhYmxlc1xyXG4gICAgY29uc3QgY29tbW9uRW52aXJvbm1lbnQgPSB7XHJcbiAgICAgIERCX1VSTDogZGJTZWNyZXQuc2VjcmV0VmFsdWVGcm9tSnNvbigndXJsJykudW5zYWZlVW53cmFwKCksXHJcbiAgICAgIERCX1VTRVI6IGRiU2VjcmV0LnNlY3JldFZhbHVlRnJvbUpzb24oJ3VzZXJuYW1lJykudW5zYWZlVW53cmFwKCksXHJcbiAgICAgIERCX1BBU1NXT1JEOiBkYlNlY3JldC5zZWNyZXRWYWx1ZUZyb21Kc29uKCdwYXNzd29yZCcpLnVuc2FmZVVud3JhcCgpLFxyXG4gICAgICBFTUFJTF9NT0RJRklDQVRJT05fQUxMT1dFRDogJ3RydWUnXHJcbiAgICB9O1xyXG5cclxuICAgIC8vIExhbWJkYSBMYXllciBmb3Igc2hhcmVkIGRlcGVuZGVuY2llcyAoSmFja3NvbiwgUG9zdGdyZVNRTCBkcml2ZXIsIFNMRjRKKVxyXG4gICAgY29uc3Qgc2hhcmVkTGF5ZXIgPSBuZXcgbGFtYmRhLkxheWVyVmVyc2lvbih0aGlzLCAnU2hhcmVkRGVwZW5kZW5jaWVzTGF5ZXInLCB7XHJcbiAgICAgIGNvZGU6IGxhbWJkYS5Db2RlLmZyb21Bc3NldCgnLi4vUHJvZmlsZU1hbmFnZXItQVBJL3RhcmdldC9sYW1iZGEtbGF5ZXInKSxcclxuICAgICAgY29tcGF0aWJsZVJ1bnRpbWVzOiBbbGFtYmRhLlJ1bnRpbWUuSkFWQV8xN10sXHJcbiAgICAgIGRlc2NyaXB0aW9uOiAnU2hhcmVkIGRlcGVuZGVuY2llcyBmb3IgcHJvZmlsZSBtYW5hZ2VtZW50IExhbWJkYSBmdW5jdGlvbnMnXHJcbiAgICB9KTtcclxuXHJcbiAgICAvLyBHZXRQcm9maWxlSGFuZGxlciBMYW1iZGEgRnVuY3Rpb25cclxuICAgIGNvbnN0IGdldFByb2ZpbGVIYW5kbGVyID0gbmV3IGxhbWJkYS5GdW5jdGlvbih0aGlzLCAnR2V0UHJvZmlsZUhhbmRsZXInLCB7XHJcbiAgICAgIHJ1bnRpbWU6IGxhbWJkYS5SdW50aW1lLkpBVkFfMTcsXHJcbiAgICAgIGhhbmRsZXI6ICdjb20ubXlvcmcudXNlcm1hbmFnZW1lbnQuaGFuZGxlci5HZXRQcm9maWxlSGFuZGxlcjo6aGFuZGxlUmVxdWVzdCcsXHJcbiAgICAgIGNvZGU6IGxhbWJkYS5Db2RlLmZyb21Bc3NldCgnLi4vUHJvZmlsZU1hbmFnZXItQVBJL3RhcmdldC9Qcm9maWxlTWFuYWdlci1BUEktMS4wLjAuamFyJyksXHJcbiAgICAgIG1lbW9yeVNpemU6IDUxMixcclxuICAgICAgdGltZW91dDogY2RrLkR1cmF0aW9uLnNlY29uZHMoMzApLFxyXG4gICAgICBlbnZpcm9ubWVudDogY29tbW9uRW52aXJvbm1lbnQsXHJcbiAgICAgIHZwYzogdnBjLFxyXG4gICAgICB2cGNTdWJuZXRzOiB7IHN1Ym5ldFR5cGU6IGVjMi5TdWJuZXRUeXBlLlBSSVZBVEVfV0lUSF9FR1JFU1MgfSxcclxuICAgICAgcm9sZTogbGFtYmRhUm9sZSxcclxuICAgICAgbGF5ZXJzOiBbc2hhcmVkTGF5ZXJdLFxyXG4gICAgICBkZXNjcmlwdGlvbjogJ1JldHJpZXZlcyB1c2VyIHByb2ZpbGUgZGF0YSAoUmVxIDE1LCAxNiknXHJcbiAgICB9KTtcclxuXHJcbiAgICAvLyBVcGRhdGVQcm9maWxlSGFuZGxlciBMYW1iZGEgRnVuY3Rpb25cclxuICAgIGNvbnN0IHVwZGF0ZVByb2ZpbGVIYW5kbGVyID0gbmV3IGxhbWJkYS5GdW5jdGlvbih0aGlzLCAnVXBkYXRlUHJvZmlsZUhhbmRsZXInLCB7XHJcbiAgICAgIHJ1bnRpbWU6IGxhbWJkYS5SdW50aW1lLkpBVkFfMTcsXHJcbiAgICAgIGhhbmRsZXI6ICdjb20ubXlvcmcudXNlcm1hbmFnZW1lbnQuaGFuZGxlci5VcGRhdGVQcm9maWxlSGFuZGxlcjo6aGFuZGxlUmVxdWVzdCcsXHJcbiAgICAgIGNvZGU6IGxhbWJkYS5Db2RlLmZyb21Bc3NldCgnLi4vUHJvZmlsZU1hbmFnZXItQVBJL3RhcmdldC9Qcm9maWxlTWFuYWdlci1BUEktMS4wLjAuamFyJyksXHJcbiAgICAgIG1lbW9yeVNpemU6IDUxMixcclxuICAgICAgdGltZW91dDogY2RrLkR1cmF0aW9uLnNlY29uZHMoMzApLFxyXG4gICAgICBlbnZpcm9ubWVudDogY29tbW9uRW52aXJvbm1lbnQsXHJcbiAgICAgIHZwYzogdnBjLFxyXG4gICAgICB2cGNTdWJuZXRzOiB7IHN1Ym5ldFR5cGU6IGVjMi5TdWJuZXRUeXBlLlBSSVZBVEVfV0lUSF9FR1JFU1MgfSxcclxuICAgICAgcm9sZTogbGFtYmRhUm9sZSxcclxuICAgICAgbGF5ZXJzOiBbc2hhcmVkTGF5ZXJdLFxyXG4gICAgICBkZXNjcmlwdGlvbjogJ1VwZGF0ZXMgdXNlciBwcm9maWxlIGRhdGEgd2l0aCB2YWxpZGF0aW9uIChSZXEgMTctMjMpJ1xyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gR2V0RW1haWxQb2xpY3lIYW5kbGVyIExhbWJkYSBGdW5jdGlvblxyXG4gICAgY29uc3QgZ2V0RW1haWxQb2xpY3lIYW5kbGVyID0gbmV3IGxhbWJkYS5GdW5jdGlvbih0aGlzLCAnR2V0RW1haWxQb2xpY3lIYW5kbGVyJywge1xyXG4gICAgICBydW50aW1lOiBsYW1iZGEuUnVudGltZS5KQVZBXzE3LFxyXG4gICAgICBoYW5kbGVyOiAnY29tLm15b3JnLnVzZXJtYW5hZ2VtZW50LmhhbmRsZXIuR2V0RW1haWxQb2xpY3lIYW5kbGVyOjpoYW5kbGVSZXF1ZXN0JyxcclxuICAgICAgY29kZTogbGFtYmRhLkNvZGUuZnJvbUFzc2V0KCcuLi9Qcm9maWxlTWFuYWdlci1BUEkvdGFyZ2V0L1Byb2ZpbGVNYW5hZ2VyLUFQSS0xLjAuMC5qYXInKSxcclxuICAgICAgbWVtb3J5U2l6ZTogMjU2LFxyXG4gICAgICB0aW1lb3V0OiBjZGsuRHVyYXRpb24uc2Vjb25kcygxMCksXHJcbiAgICAgIGVudmlyb25tZW50OiBjb21tb25FbnZpcm9ubWVudCxcclxuICAgICAgcm9sZTogbGFtYmRhUm9sZSxcclxuICAgICAgbGF5ZXJzOiBbc2hhcmVkTGF5ZXJdLFxyXG4gICAgICBkZXNjcmlwdGlvbjogJ1JldHVybnMgZW1haWwgbW9kaWZpY2F0aW9uIHBvbGljeSAoUmVxIDI1KSdcclxuICAgIH0pO1xyXG5cclxuICAgIC8vIEFQSSBHYXRld2F5IFJFU1QgQVBJXHJcbiAgICBjb25zdCBhcGkgPSBuZXcgYXBpZ2F0ZXdheS5SZXN0QXBpKHRoaXMsICdQcm9maWxlTWFuYWdlbWVudEFQSScsIHtcclxuICAgICAgcmVzdEFwaU5hbWU6ICdQcm9maWxlIE1hbmFnZW1lbnQgQVBJJyxcclxuICAgICAgZGVzY3JpcHRpb246ICdBUEkgZm9yIHVzZXIgcHJvZmlsZSBtYW5hZ2VtZW50JyxcclxuICAgICAgZGVwbG95T3B0aW9uczoge1xyXG4gICAgICAgIHN0YWdlTmFtZTogJ3Byb2QnLFxyXG4gICAgICAgIHRocm90dGxpbmdSYXRlTGltaXQ6IDEwMCxcclxuICAgICAgICB0aHJvdHRsaW5nQnVyc3RMaW1pdDogMjAwLFxyXG4gICAgICAgIGxvZ2dpbmdMZXZlbDogYXBpZ2F0ZXdheS5NZXRob2RMb2dnaW5nTGV2ZWwuSU5GTyxcclxuICAgICAgICBkYXRhVHJhY2VFbmFibGVkOiB0cnVlLFxyXG4gICAgICAgIG1ldHJpY3NFbmFibGVkOiB0cnVlXHJcbiAgICAgIH0sXHJcbiAgICAgIGRlZmF1bHRDb3JzUHJlZmxpZ2h0T3B0aW9uczoge1xyXG4gICAgICAgIGFsbG93T3JpZ2luczogYXBpZ2F0ZXdheS5Db3JzLkFMTF9PUklHSU5TLFxyXG4gICAgICAgIGFsbG93TWV0aG9kczogYXBpZ2F0ZXdheS5Db3JzLkFMTF9NRVRIT0RTLFxyXG4gICAgICAgIGFsbG93SGVhZGVyczogWydDb250ZW50LVR5cGUnLCAnQXV0aG9yaXphdGlvbiddXHJcbiAgICAgIH1cclxuICAgIH0pO1xyXG5cclxuICAgIC8vIEpXVCBBdXRob3JpemVyIChwbGFjZWhvbGRlciAtIGltcGxlbWVudCB3aXRoIENvZ25pdG8gb3IgY3VzdG9tIGF1dGhvcml6ZXIpXHJcbiAgICAvLyBjb25zdCBhdXRob3JpemVyID0gbmV3IGFwaWdhdGV3YXkuVG9rZW5BdXRob3JpemVyKHRoaXMsICdKV1RBdXRob3JpemVyJywge1xyXG4gICAgLy8gICBoYW5kbGVyOiBqd3RBdXRob3JpemVyRnVuY3Rpb24sXHJcbiAgICAvLyAgIGlkZW50aXR5U291cmNlOiAnbWV0aG9kLnJlcXVlc3QuaGVhZGVyLkF1dGhvcml6YXRpb24nXHJcbiAgICAvLyB9KTtcclxuXHJcbiAgICAvLyAvcHJvZmlsZSByZXNvdXJjZVxyXG4gICAgY29uc3QgcHJvZmlsZVJlc291cmNlID0gYXBpLnJvb3QuYWRkUmVzb3VyY2UoJ3Byb2ZpbGUnKTtcclxuXHJcbiAgICAvLyBHRVQgL3Byb2ZpbGUgLSBSZXRyaWV2ZSBwcm9maWxlXHJcbiAgICBwcm9maWxlUmVzb3VyY2UuYWRkTWV0aG9kKFxyXG4gICAgICAnR0VUJyxcclxuICAgICAgbmV3IGFwaWdhdGV3YXkuTGFtYmRhSW50ZWdyYXRpb24oZ2V0UHJvZmlsZUhhbmRsZXIsIHtcclxuICAgICAgICBwcm94eTogdHJ1ZSxcclxuICAgICAgICBpbnRlZ3JhdGlvblJlc3BvbnNlczogW1xyXG4gICAgICAgICAge1xyXG4gICAgICAgICAgICBzdGF0dXNDb2RlOiAnMjAwJyxcclxuICAgICAgICAgICAgcmVzcG9uc2VQYXJhbWV0ZXJzOiB7XHJcbiAgICAgICAgICAgICAgJ21ldGhvZC5yZXNwb25zZS5oZWFkZXIuQWNjZXNzLUNvbnRyb2wtQWxsb3ctT3JpZ2luJzogXCInKidcIlxyXG4gICAgICAgICAgICB9XHJcbiAgICAgICAgICB9XHJcbiAgICAgICAgXVxyXG4gICAgICB9KSxcclxuICAgICAge1xyXG4gICAgICAgIC8vIGF1dGhvcml6ZXI6IGF1dGhvcml6ZXIsICAvLyBFbmFibGUgaW4gcHJvZHVjdGlvblxyXG4gICAgICAgIG1ldGhvZFJlc3BvbnNlczogW1xyXG4gICAgICAgICAge1xyXG4gICAgICAgICAgICBzdGF0dXNDb2RlOiAnMjAwJyxcclxuICAgICAgICAgICAgcmVzcG9uc2VQYXJhbWV0ZXJzOiB7XHJcbiAgICAgICAgICAgICAgJ21ldGhvZC5yZXNwb25zZS5oZWFkZXIuQWNjZXNzLUNvbnRyb2wtQWxsb3ctT3JpZ2luJzogdHJ1ZVxyXG4gICAgICAgICAgICB9XHJcbiAgICAgICAgICB9XHJcbiAgICAgICAgXVxyXG4gICAgICB9XHJcbiAgICApO1xyXG5cclxuICAgIC8vIFBVVCAvcHJvZmlsZSAtIFVwZGF0ZSBwcm9maWxlXHJcbiAgICBwcm9maWxlUmVzb3VyY2UuYWRkTWV0aG9kKFxyXG4gICAgICAnUFVUJyxcclxuICAgICAgbmV3IGFwaWdhdGV3YXkuTGFtYmRhSW50ZWdyYXRpb24odXBkYXRlUHJvZmlsZUhhbmRsZXIsIHtcclxuICAgICAgICBwcm94eTogdHJ1ZSxcclxuICAgICAgICBpbnRlZ3JhdGlvblJlc3BvbnNlczogW1xyXG4gICAgICAgICAge1xyXG4gICAgICAgICAgICBzdGF0dXNDb2RlOiAnMjAwJyxcclxuICAgICAgICAgICAgcmVzcG9uc2VQYXJhbWV0ZXJzOiB7XHJcbiAgICAgICAgICAgICAgJ21ldGhvZC5yZXNwb25zZS5oZWFkZXIuQWNjZXNzLUNvbnRyb2wtQWxsb3ctT3JpZ2luJzogXCInKidcIlxyXG4gICAgICAgICAgICB9XHJcbiAgICAgICAgICB9XHJcbiAgICAgICAgXVxyXG4gICAgICB9KSxcclxuICAgICAge1xyXG4gICAgICAgIC8vIGF1dGhvcml6ZXI6IGF1dGhvcml6ZXIsICAvLyBFbmFibGUgaW4gcHJvZHVjdGlvblxyXG4gICAgICAgIG1ldGhvZFJlc3BvbnNlczogW1xyXG4gICAgICAgICAge1xyXG4gICAgICAgICAgICBzdGF0dXNDb2RlOiAnMjAwJyxcclxuICAgICAgICAgICAgcmVzcG9uc2VQYXJhbWV0ZXJzOiB7XHJcbiAgICAgICAgICAgICAgJ21ldGhvZC5yZXNwb25zZS5oZWFkZXIuQWNjZXNzLUNvbnRyb2wtQWxsb3ctT3JpZ2luJzogdHJ1ZVxyXG4gICAgICAgICAgICB9XHJcbiAgICAgICAgICB9XHJcbiAgICAgICAgXVxyXG4gICAgICB9XHJcbiAgICApO1xyXG5cclxuICAgIC8vIC9wcm9maWxlL2VtYWlsLXBvbGljeSByZXNvdXJjZVxyXG4gICAgY29uc3QgZW1haWxQb2xpY3lSZXNvdXJjZSA9IHByb2ZpbGVSZXNvdXJjZS5hZGRSZXNvdXJjZSgnZW1haWwtcG9saWN5Jyk7XHJcblxyXG4gICAgLy8gR0VUIC9wcm9maWxlL2VtYWlsLXBvbGljeSAtIEdldCBlbWFpbCBtb2RpZmljYXRpb24gcG9saWN5XHJcbiAgICBlbWFpbFBvbGljeVJlc291cmNlLmFkZE1ldGhvZChcclxuICAgICAgJ0dFVCcsXHJcbiAgICAgIG5ldyBhcGlnYXRld2F5LkxhbWJkYUludGVncmF0aW9uKGdldEVtYWlsUG9saWN5SGFuZGxlciwge1xyXG4gICAgICAgIHByb3h5OiB0cnVlLFxyXG4gICAgICAgIGludGVncmF0aW9uUmVzcG9uc2VzOiBbXHJcbiAgICAgICAgICB7XHJcbiAgICAgICAgICAgIHN0YXR1c0NvZGU6ICcyMDAnLFxyXG4gICAgICAgICAgICByZXNwb25zZVBhcmFtZXRlcnM6IHtcclxuICAgICAgICAgICAgICAnbWV0aG9kLnJlc3BvbnNlLmhlYWRlci5BY2Nlc3MtQ29udHJvbC1BbGxvdy1PcmlnaW4nOiBcIicqJ1wiXHJcbiAgICAgICAgICAgIH1cclxuICAgICAgICAgIH1cclxuICAgICAgICBdXHJcbiAgICAgIH0pLFxyXG4gICAgICB7XHJcbiAgICAgICAgLy8gYXV0aG9yaXplcjogYXV0aG9yaXplciwgIC8vIEVuYWJsZSBpbiBwcm9kdWN0aW9uXHJcbiAgICAgICAgbWV0aG9kUmVzcG9uc2VzOiBbXHJcbiAgICAgICAgICB7XHJcbiAgICAgICAgICAgIHN0YXR1c0NvZGU6ICcyMDAnLFxyXG4gICAgICAgICAgICByZXNwb25zZVBhcmFtZXRlcnM6IHtcclxuICAgICAgICAgICAgICAnbWV0aG9kLnJlc3BvbnNlLmhlYWRlci5BY2Nlc3MtQ29udHJvbC1BbGxvdy1PcmlnaW4nOiB0cnVlXHJcbiAgICAgICAgICAgIH1cclxuICAgICAgICAgIH1cclxuICAgICAgICBdXHJcbiAgICAgIH1cclxuICAgICk7XHJcblxyXG4gICAgLy8gQ2xvdWRXYXRjaCBMb2cgR3JvdXAgZm9yIEFQSSBHYXRld2F5XHJcbiAgICBuZXcgY2RrLmF3c19sb2dzLkxvZ0dyb3VwKHRoaXMsICdBUElHYXRld2F5TG9nR3JvdXAnLCB7XHJcbiAgICAgIGxvZ0dyb3VwTmFtZTogYC9hd3MvYXBpZ2F0ZXdheS8ke2FwaS5yZXN0QXBpTmFtZX1gLFxyXG4gICAgICByZXRlbnRpb246IGNkay5hd3NfbG9ncy5SZXRlbnRpb25EYXlzLk9ORV9NT05USCxcclxuICAgICAgcmVtb3ZhbFBvbGljeTogY2RrLlJlbW92YWxQb2xpY3kuREVTVFJPWVxyXG4gICAgfSk7XHJcblxyXG4gICAgLy8gT3V0cHV0c1xyXG4gICAgbmV3IGNkay5DZm5PdXRwdXQodGhpcywgJ0FQSUVuZHBvaW50Jywge1xyXG4gICAgICB2YWx1ZTogYXBpLnVybCxcclxuICAgICAgZGVzY3JpcHRpb246ICdBUEkgR2F0ZXdheSBlbmRwb2ludCBVUkwnXHJcbiAgICB9KTtcclxuXHJcbiAgICBuZXcgY2RrLkNmbk91dHB1dCh0aGlzLCAnR2V0UHJvZmlsZUZ1bmN0aW9uQXJuJywge1xyXG4gICAgICB2YWx1ZTogZ2V0UHJvZmlsZUhhbmRsZXIuZnVuY3Rpb25Bcm4sXHJcbiAgICAgIGRlc2NyaXB0aW9uOiAnR2V0UHJvZmlsZUhhbmRsZXIgTGFtYmRhIEFSTidcclxuICAgIH0pO1xyXG5cclxuICAgIG5ldyBjZGsuQ2ZuT3V0cHV0KHRoaXMsICdVcGRhdGVQcm9maWxlRnVuY3Rpb25Bcm4nLCB7XHJcbiAgICAgIHZhbHVlOiB1cGRhdGVQcm9maWxlSGFuZGxlci5mdW5jdGlvbkFybixcclxuICAgICAgZGVzY3JpcHRpb246ICdVcGRhdGVQcm9maWxlSGFuZGxlciBMYW1iZGEgQVJOJ1xyXG4gICAgfSk7XHJcblxyXG4gICAgbmV3IGNkay5DZm5PdXRwdXQodGhpcywgJ0dldEVtYWlsUG9saWN5RnVuY3Rpb25Bcm4nLCB7XHJcbiAgICAgIHZhbHVlOiBnZXRFbWFpbFBvbGljeUhhbmRsZXIuZnVuY3Rpb25Bcm4sXHJcbiAgICAgIGRlc2NyaXB0aW9uOiAnR2V0RW1haWxQb2xpY3lIYW5kbGVyIExhbWJkYSBBUk4nXHJcbiAgICB9KTtcclxuICB9XHJcbn1cclxuIl19