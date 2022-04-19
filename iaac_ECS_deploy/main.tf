#resource "aws_ecr_repository" "streamlit_ecr_repo" {
 # name ="facemaskclassifier"
#}

resource "aws_ecs_cluster" "streamlit_cluster" {
  name = "streamlit_cluster"
}



resource "aws_ecs_task_definition" "streamlit_task" {
  family = "streamlit_task"
  container_definitions = jsonencode(
    [
    {
      name      = "streamlit_task"
      image     = "148465220356.dkr.ecr.us-east-1.amazonaws.com/facemaskclassifier"
      essential = true
      portMappings = [
        {
          containerPort = 8501
          hostPort      = 8501
        }
      ]
      memory = 512
      cpu    = 256
    }
  ])
  
  requires_compatibilities = ["FARGATE","EC2"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"


}


resource "aws_ecs_service" "streamlit_service" {
  name            = "streamlit_service"
  cluster         = aws_ecs_cluster.streamlit_cluster.id
  task_definition = aws_ecs_task_definition.streamlit_task.arn
  desired_count   = 3
  launch_type       = "FARGATE"
  platform_version  = "LATEST"

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn # Referencing our target group
    container_name   = aws_ecs_task_definition.streamlit_task.family
    container_port   = 8501 # Specifying the container port
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
    
    security_groups  = [aws_security_group.service_sg.id]
    assign_public_ip = true


  }

}


# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}


resource "aws_alb" "application_load_balancer" {
  name               = "streamlit-lb"
  load_balancer_type = "application"

  subnets = [
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    aws_default_subnet.default_subnet_c.id

  ]

  security_groups = [aws_security_group.lb_sg.id]

}


resource "aws_security_group" "lb_sg" {
  ingress {
    from_port   = 8501 # Allowing traffic in from port 80
    to_port     = 8501

    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}


resource "aws_security_group" "service_sg" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}





resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb-target-group"
  port        = 8501
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  health_check {
    matcher = "200"
    path    = "/"
  }

}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 8501
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

