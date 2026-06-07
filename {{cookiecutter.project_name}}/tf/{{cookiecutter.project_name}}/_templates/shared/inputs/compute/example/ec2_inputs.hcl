inputs = {
  instances = {
    "example-instance-tf" = {
      ami               = "ami-xxxxxxxxxxxxxxxxx"
      instance_type     = "t3.medium"
      subnet_id         = "example-vpc/example-public-subnet-1a"
      availability_zone = "us-east-1a"

      key_name = {
        name     = "example-key-tf"
        existing = false
      }

      security_group_names        = ["example-sg-tf"]
      associate_public_ip_address = true

      ebs_optimized         = true
      delete_on_termination = true
      root_volume_size      = 20
      root_volume_type      = "gp3"

      tags = {
        "Name"         = "example-instance-tf"
        "Project"      = "{{cookiecutter.project_name}}"
        "AnsibleGroup" = "example"
      }
    }
  }
}