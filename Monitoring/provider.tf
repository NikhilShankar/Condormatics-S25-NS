provider "aws" {
  region = local.default_region
}

resource "random_integer" "s3_bucket_suffix" {
  min = 10000
  max = 99999
}