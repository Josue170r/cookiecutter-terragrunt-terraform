inputs = {
  vpcs = {
    "example-vpc" = {
      cidr_block           = "10.0.0.0/16"
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags = {
        "Name"    = "example-vpc"
        "Project" = "{{cookiecutter.project_name}}"
      }

      subnets = {
        "example-public-subnet-1a" = {
          cidr_block        = "10.0.1.0/24"
          availability_zone = "us-east-1a"
          tags = {
            "Name" = "example-public-subnet-1a"
          }
        }
        "example-private-subnet-1a" = {
          cidr_block        = "10.0.2.0/24"
          availability_zone = "us-east-1a"
          tags = {
            "Name" = "example-private-subnet-1a"
          }
        }
      }

      internet_gateways = {
        "example-igw" = {
          tags = {
            "Name" = "example-igw"
          }
        }
      }

      nat_gateways = {
        "example-nat" = {
          subnet_id = "example-public-subnet-1a"
          tags = {
            "Name" = "example-nat"
          }
        }
      }

      route_tables = {
        "example-public-rt" = {
          tags = {
            "Name" = "example-public-rt"
          }
          routes = [
            {
              cidr_block = "0.0.0.0/0"
              igw_id     = "example-igw"
            }
          ]
          subnet_associations = ["example-public-subnet-1a"]
        }
        "example-private-rt" = {
          tags = {
            "Name" = "example-private-rt"
          }
          routes = [
            {
              cidr_block     = "0.0.0.0/0"
              nat_gateway_id = "example-nat"
            }
          ]
          subnet_associations = ["example-private-subnet-1a"]
        }
      }
    }
  }
}