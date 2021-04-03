provider "aws" {
    region="ap-south-1"
}
#creating s3 bucket
resource "aws_s3_bucket" "mybucket"{
    bucket="mybucket1908"
    acl="public-read"
    versioning {
      enabled=true
    }
    website {
      index_document="index.html"
      error_document="error.html"
    }
    tags= {
        Name="Mysimplebucket"
        Environment="Dev"
    }
}
#creating html pages in s3 bucket as objects
resource "aws_s3_bucket_object" "test" {
  for_each = fileset(path.module ,"**/*.html") 
      bucket = aws_s3_bucket.mybucket.bucket
      key=each.value 
      source = "${path.module}/${each.value}"
}
output "fileset-results" {
  value = fileset(path.module ,"**/*.html")      
}

output "bucketname" {
  value= aws_s3_bucket.mybucket.bucket
}

#creating policy for S3
resource "aws_s3_bucket_policy" "default"{
    bucket=aws_s3_bucket.mybucket.bucket
    policy = data.aws_iam_policy_document.default.json
}
data "aws_iam_policy_document" "default"{
    statement {
      actions=["s3:GetObject"]
      resources=["${aws_s3_bucket.mybucket.arn}/*"]
      principals {
        type="AWS"
        identifiers=["*"]
      }
    }
}