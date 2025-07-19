variable "instance_type" {
  type      = string
  sensitive = false
  default   = "t3.micro"
}

variable "resource_tags" {
  type      = map(string)
  sensitive = false
  default   = { "us-east-1" : "us-east-1" }
}

variable "core_count" {
  type = number
}

variable "thread_count" {
  type = number
}

variable "public_subnet_cidr_blocks" {
  type      = list(string)
  sensitive = false
  default   = ["10.0.0.0/24", "10.0.1.0/24"]
}