module "ingres_alb" {
  source                = "terraform-aws-modules/alb/aws"
  internal              = false
  name                  = "${local.resource_name}-ingress-alb"
  vpc_id                = local.vpc_id
  subnets               = local.public_subnet_ids
  security_groups       = [data.aws_ssm_parameter.ingress_alb_sg.value]
  create_security_group = false
  tags = merge(
    var.common_tags,
    var.ingress_alb_tags
  )
   enable_deletion_protection = false
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = module.ingres_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from APPlication ALB</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.ingres_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_certificate_arn

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from web ALB HTTPS</h1>"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  zone_name = var.zone_name
  records = [
    {
      name    = "expense-${var.environment}"
      type    = "A"
      alias   = {
        name    = module.ingres_alb.dns_name
        zone_id = module.ingres_alb.zone_id
      }
      allow_overwrite = true
    }
  ]
}


resource "aws_lb_target_group" "expense_tg" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  target_type = "ip"
  health_check {
    healthy_threshold   = 2 #if contineously two request sucess means its healthy
    unhealthy_threshold = 2 #if contineously two request fail means its unhealthy
    interval            = 5
    matcher             = "200-299"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 4
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100 #low priority evaluated first 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.expense_tg.arn
  }
  condition {
    host_header {
      values = ["expense-${var.environment}.${var.zone_name}"] #expense-dev.basavadevops81s.online
    }
  }
}
