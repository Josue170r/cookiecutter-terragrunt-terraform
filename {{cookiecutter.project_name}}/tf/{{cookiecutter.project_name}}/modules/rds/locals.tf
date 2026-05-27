locals {
  instances = { for k, v in var.db_instances : k => v if v.db_instance_type == "instance" }
  clusters  = { for k, v in var.db_instances : k => v if v.db_instance_type == "cluster" }
}
