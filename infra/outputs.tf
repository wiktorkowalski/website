output "bucket_url" {
  value = "s3://${aws_s3_bucket.website_bucket.id}"
}

output "website_url" {
  value = "https://${tolist(aws_cloudfront_distribution.website_distribution.aliases)[0]}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website_distribution.id
}