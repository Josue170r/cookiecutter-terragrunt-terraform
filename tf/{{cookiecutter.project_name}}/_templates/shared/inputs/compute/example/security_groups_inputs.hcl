inputs = {
  security_groups = {
    "example-sg" = {
      name        = "example-sg"
      description = "Example security group"
      vpc_id      = "example-vpc"
      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      tags = {
        Name    = "example-sg"
        Project = "{{cookiecutter.project_name}}"
      }
    }
  }
}