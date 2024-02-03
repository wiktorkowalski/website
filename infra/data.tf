// import existing aws route 53 zone
data "aws_route53_zone" "wiktorkowalski" {
  name = var.main_domain_name
}