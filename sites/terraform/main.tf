provider "aws" {

    # profile refers to the user profile we are using to connect to AWS
    # It is available after installing AWS CLI and running command aws configure

    profile = "default"
}

module "s3_bucket" {

    source = "terraform-aws-modules/s3-bucket/aws"

    bucket = "VAR_AWS_S3_BUCKET_NAME"

    acl    = "public-read"

    attach_policy = true

    policy = "${file("policy.json")}"

    website = {
        index_document = "index.html"
        error_document = "404.html"
    }

    cors_rule = {
        allowed_headers = ["*"]
        allowed_methods = ["GET"]
        allowed_origins = ["*"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
    }

    versioning = {
        enabled = true
    }
}
