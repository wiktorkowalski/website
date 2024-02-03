variable "main_domain_name" {
  description = "The main domain name"
  type        = string
  default = "wiktorkowalski.pl"
}

variable "domain_aliases" {
  description = "The domain aliases"
  type        = list(string)
  default = ["www.wiktorkowalski.pl"]
}

variable "website_bucket_name" {
  description = "The name of the S3 bucket for the website"
  type        = string
  default = "wiktorkowalski-website"
}

variable "aws_region" {
  description = "Main AWS region"
  type        = string
  default = "eu-west-1"
}
