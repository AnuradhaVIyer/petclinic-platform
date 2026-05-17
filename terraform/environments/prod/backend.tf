terraform {
  backend "s3" {
    bucket         = "petclinic-terraform-state-749635699241"
    key            = "petclinic/prod/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile = true   # replaces dynamodb_table
    encrypt        = true
  }
}
