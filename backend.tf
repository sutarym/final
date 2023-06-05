terraform {
  backend "s3" {
    bucket = "delete-bucket-yasin"
    key    = "terraform.tfstate"
    region = "ap-south-1"
      access_key = "AKIAXQM6UOUEOIAQPH2C"
  secret_key = "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"
  }
}
