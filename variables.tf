variable "region" {
  description = "AWS region of the existing VPC/IGW"
  type        = string
  default     = "ap-northeast-3"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-00ffe463659a905fd"
}

variable "igw_id" {
  description = "Existing Internet Gateway ID"
  type        = string
  default     = "igw-0ab67e09d24810be0"
}

variable "subnet_cidr" {
  description = "Your subnet CIDR"
  type        = string
  default     = "10.0.19.0/24"
}

variable "name_prefix" {
  description = "Prefix for naming/tagging resources"
  type        = string
  default     = "Richard"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR, e.g., 102.89.1.23/32"
  type        = string
  default     = "0.0.0.0/0"
}
