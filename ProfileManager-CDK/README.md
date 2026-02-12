# Infrastructure as Code (AWS CDK)

AWS CDK infrastructure for user authentication system.

## Technology Stack
- AWS CDK (TypeScript)
- CloudFormation
- AWS Lambda
- API Gateway
- RDS PostgreSQL
- Secrets Manager
- SES
- CloudWatch

## Project Structure
```
lib/
├── database-stack.ts       # RDS PostgreSQL
├── lambda-stack.ts         # Lambda functions
├── api-gateway-stack.ts    # API Gateway
├── secrets-stack.ts        # Secrets Manager
└── monitoring-stack.ts     # CloudWatch
```

## Setup
```bash
npm install
```

## Deploy
```bash
# Deploy to dev environment
cdk deploy --all --context env=dev

# Deploy to prod environment
cdk deploy --all --context env=prod
```

## Destroy
```bash
cdk destroy --all
```

## Useful Commands
- `cdk ls` - List all stacks
- `cdk synth` - Synthesize CloudFormation template
- `cdk diff` - Compare deployed stack with current state
- `cdk docs` - Open CDK documentation
