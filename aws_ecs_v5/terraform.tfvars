name                = "my-app"
environment         = "test"
availability_zones  = ["eu-central-1a", "eu-central-1b"]
private_subnets     = ["10.0.0.0/20", "10.0.32.0/20"]
public_subnets      = ["10.0.16.0/20", "10.0.48.0/20"]
tsl_certificate_arn = "arn:aws:acm:eu-central-1:632296647497:certificate/e2dc93cc-96d2-4d00-8b60-3f754af11e95"
container_memory    = 512
container_image     = "public.ecr.aws/m2a7z1o1/frontend-app"