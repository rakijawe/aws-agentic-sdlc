import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as rds from 'aws-cdk-lib/aws-rds';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';

/**
 * CDK Stack for Profile Management Lambda Functions and API Gateway
 * Requirements: Req 15-25 (Profile Management)
 * Phase: 7 - Testing & Deployment
 */
export class ProfileLambdaStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Import existing VPC (or create new one)
    const vpc = ec2.Vpc.fromLookup(this, 'VPC', {
      isDefault: true
    });

    // Import existing database secret
    const dbSecret = secretsmanager.Secret.fromSecretNameV2(
      this,
      'DBSecret',
      'profilemanager/db-credentials'
    );

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
    profileResource.addMethod(
      'GET',
      new apigateway.LambdaIntegration(getProfileHandler, {
        proxy: true,
        integrationResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': "'*'"
            }
          }
        ]
      }),
      {
        // authorizer: authorizer,  // Enable in production
        methodResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': true
            }
          }
        ]
      }
    );

    // PUT /profile - Update profile
    profileResource.addMethod(
      'PUT',
      new apigateway.LambdaIntegration(updateProfileHandler, {
        proxy: true,
        integrationResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': "'*'"
            }
          }
        ]
      }),
      {
        // authorizer: authorizer,  // Enable in production
        methodResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': true
            }
          }
        ]
      }
    );

    // /profile/email-policy resource
    const emailPolicyResource = profileResource.addResource('email-policy');

    // GET /profile/email-policy - Get email modification policy
    emailPolicyResource.addMethod(
      'GET',
      new apigateway.LambdaIntegration(getEmailPolicyHandler, {
        proxy: true,
        integrationResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': "'*'"
            }
          }
        ]
      }),
      {
        // authorizer: authorizer,  // Enable in production
        methodResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': true
            }
          }
        ]
      }
    );

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
