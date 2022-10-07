## Usage
```sh
terraform {
  backend "s3" {
    bucket         = "dakual-terraform-state"
    key            = "state/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    kms_key_id     = "alias/terraform-bucket-key"
    dynamodb_table = "terraform-state"
  }
}
```