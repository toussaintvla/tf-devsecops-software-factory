variable "devsecops_factory_name" {
  description = "Name of the DevSecOps Software Factory, used to name other resources"
  type        = string
  default     = "devsecops-factory"
}

variable "region" {
  default = "us-east-2"
}

variable "branch_name" {
  type        = string
  description = "Git repository branch name"
  default     = "master"
}

variable "repository_name" {
  type        = string
  description = "Git repository name"
  default     = "software-factory"
}

variable "sast_tool" {
  type        = list(string)
  description = "Select the SAST tool from the list"
  default     = ["Anchore", "Snyk"]
}

variable "dast_tool" {
  type        = list(string)
  description = "Select the DAST tool from the list"
  default     = ["OWASP-Zap"]
}

variable "owasp_zap_url_name" {
  type        = string
  description = "OWASP Zap DAST Tool URL"
  default     = "http://18.221.16.46:81/"
}

variable "app_url_dast_scan" {
  type        = string
  description = "Application URL to run the DAST/Pen testing"
  default     = "https://eksstg.smanepalli.com"
}

variable "owasp_zap_api_key" {
  type        = string
  description = "OWASP Zap ApiKey"
  sensitive   = true
  default     = "zapapikey"
}

variable "snyk_api_key" {
  type        = string
  description = "Snyk ApiKey"
  sensitive   = true
  default     = "synkapikey"
}

variable "pipeline_notifications_email" {
  type        = string
  description = "Email address to receive SNS notifications for pipelineChanges"
  default     = "tpatrick1496@gmail.com"
}

variable "pipeline_approver_email" {
  type        = string
  description = "Email address to send approval notifications"
  default     = "tpatrick1496@gmail.com"
}

variable "ecr_nonprod_repository" {
  type        = string
  description = "Container image repository"
  default     = "wordpress-staging"
}

variable "ecr_prod_repository" {
  type        = string
  description = "Container image repository"
  default     = "wordpress-prod"
}

variable "eks_nonprod_cluster" {
  type        = string
  description = "The name of the EKS cluster created"
  default     = "kubernetes-nonprod-cluster"
}

variable "eks_prod_cluster" {
  type        = string
  description = "The name of the EKS cluster created"
  default     = "kubernetes-nonprod-cluster"
}

variable "devsecops_factory_code" {
  type        = string
  description = "Path of the compressed lambda source code."
  default     = "src/import_findings_security_hub.zip"
}