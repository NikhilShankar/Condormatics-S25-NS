variable "project_name" {
  description = "Name of the project to be used as prefix for all resources"
  type        = string
  
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name cannot be empty."
  }
}