resource "aws_ssm_parameter" "devsecops_factory_snyk_api_key" {
  name        = "${var.devsecops_factory_name}-snyk-api-key"
  description = "DevSecOps Software Factory - Snyk API Key"
  type        = "SecureString"
  value       = var.snyk_api_key
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "devsecops_factory_owasp_zap_api_key" {
  name        = "${var.devsecops_factory_name}-owasp-zap-api-key"
  description = "DevSecOps Software Factory - OWASP ZAP API Key"
  type        = "SecureString"
  value       = var.owasp_zap_api_key
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "devsecops_factory_owasp_zap_url" {
  name        = "${var.devsecops_factory_name}-owasp-zap-url"
  description = "DevSecOps Software Factory - OWASP ZAP URL"
  type        = "SecureString"
  value       = var.owasp_zap_url_name
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "devsecops_factory_dast_app_url" {
  name        = "${var.devsecops_factory_name}-dast-app-url"
  description = "DevSecOps Software Factory - DAST App URL"
  type        = "SecureString"
  value       = var.app_url_dast_scan
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}