inputs = {
  db_instances = {
    "example-db-tf" = {
      db_instance_type = "instance"

      engine         = "postgres"
      engine_version = "15.4"
      instance_class = "db.t3.medium"

      allocated_storage     = 20
      max_allocated_storage = 100
      storage_type          = "gp3"
      storage_encrypted     = true

      db_name  = "exampledb"
      username = "dbadmin"
      port     = 5432

      multi_az   = false
      subnet_ids = [
        "example-vpc/example-private-subnet-1a"
      ]
      vpc_security_group_ids = ["example-sg-tf"]

      backup_retention_period = 7
      backup_window           = "03:00-04:00"
      maintenance_window      = "mon:04:00-mon:05:00"

      skip_final_snapshot = false
      deletion_protection = true
      publicly_accessible = false

      tags = {
        "Name"    = "example-db-tf"
        "Project" = "{{cookiecutter.project_name}}"
      }
    }
  }
}