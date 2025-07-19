resource "aws_s3_bucket" "web_bucket" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = var.resource_tags
}

resource "aws_s3_object" "htmlfile" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/webcontent/index.html"
  source = "./webcontent/index.html"

  tags = var.resource_tags
}

resource "aws_s3_object" "stylesheet" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/webcontent/styles.css"
  source = "./webcontent/styles.css"

  tags = var.resource_tags
}

resource "aws_s3_object" "programsimg" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/webcontent/programs.jpg"
  source = "./webcontent/programs.jpg"

  tags = var.resource_tags
}

resource "aws_s3_object" "studentsimg" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/webcontent/students.jpg"
  source = "./webcontent/students.jpg"

  tags = var.resource_tags
}

