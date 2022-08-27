### Creating new Topic
```sh
aws sns create-topic --name TestTopic
```

### Creating new Subscribe
```sh
aws sns subscribe  --topic-arn arn:aws:sns:eu-central-1:123456789012:TestTopic \
                     --protocol https \
                     --notification-endpoint example.com
```

### Answer confirmation (in the Header)     
x-amz-sns-message-type:SubscriptionConfirmation

### Publish messages
```sh
aws sns publish --topic-arn "arn:aws:sns:eu-central-1:123456789012:TestTopic" \
                  --message "first message"
```

### Creating new Queue
```sh
aws sqs create-queue --queue-name TestQueue
```

### Send message to Queue
```sh
aws sqs send-message --queue-url https://eu-central-1.queue.amazonaws.com/123456789012/TestQueue --message-body "first message"
```

### Receive message from Queue
```sh
aws sqs receive-message --queue-url https://eu-central-1.queue.amazonaws.com/123456789012/TestQueue
```

### Delete message from Queue
```sh
aws sqs delete-message --queue-url https://eu-central-1.queue.amazonaws.com/123456789012/TestQueue --receipt-handle <...>
```
  