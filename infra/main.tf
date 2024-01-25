terraform {
  backend "s3" {
    bucket = "wiktorkowalski-terraform-state"
    key    = "website/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "wiktorkowalski-terraform-state"
    encrypt = false
  }
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.32.1"
    }
  }
}

// aws
provider "aws" {
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
}

// import existing aws route 53 zone
data "aws_route53_zone" "wiktorkowalski" {
  name = "wiktorkowalski.pl"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "wiktorkowalski-website"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_bucket,
    aws_s3_bucket_public_access_block.website_bucket,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:PutBucketPolicy",
        "s3:GetBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::wiktorkowalski-website",
        "arn:aws:s3:::wiktorkowalski-website/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for website"
}

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code = 403
    response_code = 200
    response_page_path = "/index.html"
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [ "wiktorkowalski.pl", "www.wiktorkowalski.pl" ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.bucket_regional_domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

resource "aws_acm_certificate" "cert" {
  provider                  = aws.us-east-1
  domain_name               = "wiktorkowalski.pl"
  subject_alternative_names = ["www.wiktorkowalski.pl"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "certvalidation" {
  for_each = {
    for d in aws_acm_certificate.cert.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.wiktorkowalski.zone_id
}

resource "aws_acm_certificate_validation" "certvalidation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}

resource "aws_route53_record" "url" {
  zone_id = data.aws_route53_zone.wiktorkowalski.zone_id
  name    = "wiktorkowalski.pl"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.wiktorkowalski.zone_id
  name    = "www.wiktorkowalski.pl"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

output "bucket_url" {
  value = "s3://${aws_s3_bucket.website_bucket.id}"
}

output "website_url" {
  value = "https://${tolist(aws_cloudfront_distribution.website_distribution.aliases)[0]}"
}
