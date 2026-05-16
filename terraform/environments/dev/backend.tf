terraform {
  backend "s3" {
    bucket         = "petclinic-terraform-state-749635699241"
    key            = "petclinic/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "petclinic-terraform-locks"
    encrypt        = true
  }
}
