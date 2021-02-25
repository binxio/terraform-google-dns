variable "environment" {
  description = "Allows us to use random environment for our tests"
  type        = string
}

variable "project" {
  description = "Allows us to use random project for our tests"
  type        = string
}

variable "location" {
  description = "Allows us to use random location for our tests"
  type        = string
}

variable "owner" {
  description = "Owner used for tagging"
  type        = string
}

variable "test_vpc" {
  description = "The test VPC made in prereq to test against"
  type        = string
  default     = ""
}
