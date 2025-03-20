variable "region" {
  default = "us-east-1"
}

variable "repo_name" {
  default = "ruby-app"
}

variable "app_name" {
  default = "ruby-app"
}

variable "cluster_name" {
  default = "ruby-cluster"
}

variable "service_name" {
  default = "ruby-service"
}

variable "branch_name" {
  default = "master"
}

variable "github_repo_name" {
  default = "parmar-gaurav-devops/devops-challenge"
}


variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-036b17c3f5da216aa", "subnet-04887423b8922dc97"]
}

variable "security_group_id" {
  type = list(string)
  default = ["sg-0b4bdadc20b84a176"]
}