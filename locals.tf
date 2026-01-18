locals {
  common_tags = {
    company      = var.company_name
    Project      = var.project_name
    environment  = var.environment
    billing_code = var.billing_code
  }
  prefix = "${var.project_name}-${var.environment}"
}

