terraform {
  backend "s3" {
    bucket = "delete-bucket-yasin"
    key    = "terraform.tfstate"
    region = "ap-south-1"
      access_key = "AKIAXQM6UOUEPNWGC7MB"
  secret_key = "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"
  }
}
