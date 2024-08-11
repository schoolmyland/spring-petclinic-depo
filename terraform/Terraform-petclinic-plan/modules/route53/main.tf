# CREATE ZONE 

resource "aws_route53_zone" "main" {
  name = var.domain
}


# CERTIFICAT AND RECORD



# Customer 1
resource "aws_acm_certificate" "certcus1" {

  domain_name       = "${var.customer1}.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  validation_option {
    domain_name          = "${var.customer1}.${var.domain}"
    validation_domain    = var.domain
  }
}

resource "aws_route53_record" "certcus1" {
  for_each = {
    for dvo in aws_acm_certificate.certcus1.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}


# Customer 2
resource "aws_acm_certificate" "certcus2" {

  domain_name       = "${var.customer2}.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  validation_option {
    domain_name          = "${var.customer2}.${var.domain}"
    validation_domain    = var.domain
  }
}

resource "aws_route53_record" "certcus2" {
  for_each = {
    for dvo in aws_acm_certificate.certcus2.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# monitoring 
resource "aws_acm_certificate" "certmon" {

  domain_name       = "monitoring.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  validation_option {
    domain_name          = "monitoring.${var.domain}"
    validation_domain    = var.domain
  }
}

resource "aws_route53_record" "certmon" {
  for_each = {
    for dvo in aws_acm_certificate.certmon.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}


