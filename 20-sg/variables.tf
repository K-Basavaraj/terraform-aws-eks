variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}


variable "common_tags" {
  default = {
    Project     = "expense"
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "mysql_sg_tags" {
  default = {
    Component = "mysql"
  }
}

# variable "node_sg_tags" {
#   default = {
#     Component = "node"
#   }
# }

# variable "control_plane_sg_tags" {
#   default = {
#     Component = "control_plane"
#   }
# }

# variable "ingress_alb_sg_tags" {
#   default = {
#     Component = "ingress_alb"
#   }
# }

# variable "bastion_sg_tags" {
#    default = {
#     Component = "bastion"
#   }
# }
