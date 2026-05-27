inputs = {
  db_instances = {
    "example-db" = {
      identifier             = "example-db"
      engine                 = "aurora-postgresql"
      instance_class         = "db.t3.medium"
      subnet_ids             = ["example-subnet-1", "example-subnet-2"]
      vpc_security_group_ids = ["example-sg"]
      password_env_var       = "DB_PASSWORD_EXAMPLE"
      tags = {
        Name    = "example-db"
        Project = "{{cookiecutter.project_name}}"
      }
    }
  }
}