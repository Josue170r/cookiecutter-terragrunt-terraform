inputs = {
  security_groups = {
    "example-sg-tf" = {
      description = "Security group de ejemplo"
      vpc_id      = "example-vpc"
      tags = {
        "Name" = "example-sg-tf"
      }

      ingress = {
        ###### Inicio sg-rule ######
        "ssh-access" = {
          from_port   = 22
          to_port     = 22
          protocol    = "TCP"
          cidr_blocks = ["10.0.0.0/8"]
          description = "SSH access"
        }
        ###### Fin sg-rule ######

        ###### Inicio sg-rule ######
        "http-access" = {
          from_port   = 80
          to_port     = 80
          protocol    = "TCP"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP access"
        }
        ###### Fin sg-rule ######
      }

      egress = {
        "all_outbound" = {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Permitir todo el trafico saliente"
        }
      }
    }
  }
}