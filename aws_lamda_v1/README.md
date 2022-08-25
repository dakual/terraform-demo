### Invoke lambda function using the AWS CLI.
```sh
aws lambda invoke --region=eu-central-1 --function-name=$(terraform output -raw function_name) response.json
cat response.json
```

### Now, send a request to API Gateway to invoke the Lambda function using curl.
```sh
curl "$(terraform output -raw base_url)/hello"
curl "$(terraform output -raw base_url)/hello?Name=Terraform"
```