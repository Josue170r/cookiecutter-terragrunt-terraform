inputs = {
  instances = {
    "example-instance" = {
      ami           = "ami-xxxxxxxxxxxxxxxxx"
      instance_type = "t3.medium"
      subnet_id     = "example-subnet"
      key_name      = "example-key"
      tags = {
        Name    = "example-instance"
        Project = "{{cookiecutter.project_name}}"
      }
    }
  }
}