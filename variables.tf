variable "component" {
  description = "Component name, will be used to generate names for created resources"
  type        = string
  default     = "nat"
}

variable "project" {
  description = "Project name, will be used to generate names for created resources"
  type        = string
  default     = "k3s"
}

variable "tags" {
  description = "Tags to attach to resources"
  default     = {}
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances created by AutoScaling Group"
  type        = string
}

variable "ssh_key_name" {
  description = "Key pair name for SSH"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.micro"
}

variable "domain" {
  description = "If supplied, EC2 instance will put its public ip to public Route53 zone"
  type        = string
  default     = null
}

variable "private_domain" {
  description = "If supplied, EC2 instance will put its private ip to private Route53 zone"
  type        = string
  default     = null
}

variable "record_ttl" {
  description = "Time to live for DNS entries created by EC2 instance"
  type        = number
  default     = 30
}

variable "record_name" {
  description = "If supplied domain is 'example.com' and record_name set to 'sub' then 'sub.example.com' will be put to Route53 zone"
  type        = string
  default     = null
}

variable "create_sg" {
  description = "Flag indicating whether security group should be created"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "List of additional security groups to attach to EC2 instances"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Flag indicating whether public ip should be associated"
  default     = true
}

# THIS MODULE -----------------------------------------------------------------

variable "vpc_cidr" {
  type    = string
  default = null
}

variable "public_subnet" {
  type    = string
  default = null
}

variable "private_subnet" {
  type    = string
  default = null
}

variable "availability_zone" {
  type    = string
  default = null
}