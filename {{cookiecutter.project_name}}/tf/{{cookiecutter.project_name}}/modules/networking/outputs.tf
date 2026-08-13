# outputs.tf
output "vpcs" {
  value = {
    for k, v in aws_vpc.this : k => {
      id         = v.id
      cidr_block = v.cidr_block
      arn        = v.arn
    }
  }
}

output "subnets" {
  value = {
    for k, v in aws_subnet.this : k => {
      id                = v.id
      cidr_block        = v.cidr_block
      availability_zone = v.availability_zone
      vpc_id            = v.vpc_id
    }
  }
}

output "subnet_arns" {
  value = { for k, v in aws_subnet.this : k => v.arn }
}

output "vpc_ids" {
  value = { for k, v in aws_vpc.this : k => v.id }
}

output "nat_gateway_eip_ids" {
  value = { for k, v in aws_eip.nat : k => v.allocation_id }
}

output "subnet_ids" {
  value = { for k, v in aws_subnet.this : k => v.id }
}

output "internet_gateway_ids" {
  value = { for k, v in aws_internet_gateway.this : k => v.id }
}

output "nat_gateway_ids" {
  value = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "route_table_ids" {
  value = merge(
    { for k, v in aws_route_table.managed : k => v.id },
    { for k, v in aws_route_table.imported : k => v.id }
  )
}

output "vpc_endpoint_ids" {
  value = { for k, v in aws_vpc_endpoint.gateway : k => v.id }
}
