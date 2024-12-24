
terraform {
  backend "s3" {
    bucket         = "powertool9087"
    key            = "ansible/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "powertool"
  }
}
