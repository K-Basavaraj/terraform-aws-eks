##########################SECURITY_GROUPS################ 
module "mysql_sg" {
  source       = "../../terraform-aws-secuirty-group"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "mysql"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.mysql_sg_tags
}

module "bastion_sg" {
  source       = "../../terraform-aws-secuirty-group"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "bastion"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  #sg_tags      = var.bastion_sg_tags
}

module "node_sg" {
  source       = "../../terraform-aws-secuirty-group"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "node"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  #sg_tags      = var.node_sg_tags
}

module "control_plane_sg" {
  source       = "../../terraform-aws-secuirty-group"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "eks-control-plane"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  #sg_tags      = var.control_plane_sg_tags
}

module "ingress_alb_sg" {
  source       = "../../terraform-aws-secuirty-group"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "ingress_alb"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  #sg_tags      = var.ingress_alb_sg_tags
}


###############SECURITY_GROUP_RULES################################
#we need to allow traffic from internet to ingressalb
resource "aws_security_group_rule" "ingress_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress_alb_sg.id #where your creating this rule
}

#eks control plane receving trffaic from node/workernode
resource "aws_security_group_rule" "eks_control_plane_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.node_sg.id          #accepting connections
  security_group_id        = module.control_plane_sg.id #where your creating this rule
}

#eks control plane receving trffaic from bastion
resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id          #accepting connections
  security_group_id        = module.control_plane_sg.id #where your creating this rule
}

#node/workernode receving traffic from controlplane
resource "aws_security_group_rule" "node_eks_control_plane" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.control_plane_sg.id #accepting connections
  security_group_id        = module.node_sg.id          #where your creating this rule
}

#we need to allow traffic from ingressalb to workenodes/node
resource "aws_security_group_rule" "node_ingress_alb" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  source_security_group_id = module.ingress_alb_sg.id   #accepting connections
  security_group_id        = module.node_sg.id          #where your creating this rule
}

#node/workernode receving traffic from vpccidr for pod to pod communication 
resource "aws_security_group_rule" "node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]   #accepting connections from vpc all internal
  security_group_id = module.node_sg.id #where your creating this rule
}

#workernode/node accepting connection from bastion
resource "aws_security_group_rule" "node_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id #accept connection from this source
  security_group_id        = module.node_sg.id    #where your creating this rule
}

#mysql accepting connection from bastion
resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id #accept connection from this source
  security_group_id        = module.mysql_sg.id   #where your creating this rule
}

#bastion accepting connection from internet
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.id #where your creating this rule
}
