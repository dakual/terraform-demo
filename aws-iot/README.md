```sh
terraform init
terraform apply --auto-approve
export AWS_IOT_ENDPOINT=$(terraform output iot_endpoint)
```

```sh
python3 publish.py
```

```sh
mosquitto_pub -h iot.example.com --cafile AmazonRootCA1.pem --cert TestThing.cert.pem --key TestThing.private.key -p 8883 -q 1 -d -t test/device/TestThing -i TestThing -m "{\"message\": \"helloFromTestThing\"}"
```