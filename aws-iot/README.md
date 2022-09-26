```sh
terraform init
terraform apply --auto-approve
export AWS_IOT_ENDPOINT=$(terraform output iot_endpoint)
```

```sh
python3 publish.py
```