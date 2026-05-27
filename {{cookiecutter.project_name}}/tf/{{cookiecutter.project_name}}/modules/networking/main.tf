resource "aws_vpc" "this" {
  for_each             = var.vpcs
  cidr_block           = each.value.cidr_block
  enable_dns_support   = each.value.enable_dns_support
  enable_dns_hostnames = each.value.enable_dns_hostnames
  tags                 = each.value.tags
}

resource "aws_subnet" "this" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.this[each.value.vpc_name].id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}

resource "aws_internet_gateway" "this" {
  for_each = local.internet_gateways
  vpc_id   = aws_vpc.this[each.value.vpc_name].id
  tags     = each.value.tags
}

resource "aws_eip" "nat" {
  for_each = local.nat_gateways
  domain   = "vpc"
  tags     = each.value.tags
}

resource "aws_nat_gateway" "this" {
  for_each      = local.nat_gateways
  subnet_id     = aws_subnet.this[each.value.subnet_id].id
  allocation_id = aws_eip.nat[each.key].id
  tags          = each.value.tags

  depends_on = [aws_internet_gateway.this]
}

# Created by Terraform
resource "aws_route_table" "managed" {
  for_each = local.managed_route_tables

  vpc_id = aws_vpc.this[each.value.vpc_name].id
  tags   = each.value.tags

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block     = route.value.cidr_block
      gateway_id     = route.value.igw_id != null ? aws_internet_gateway.this[route.value.igw_id].id : null
      nat_gateway_id = route.value.nat_gateway_id != null ? aws_nat_gateway.this[route.value.nat_gateway_id].id : null
    }
  }
}

# Imported from AWS Current Infraestructure
resource "aws_route_table" "imported" {
  for_each = local.imported_route_tables

  vpc_id = aws_vpc.this[each.value.vpc_name].id
  tags   = each.value.tags

  lifecycle {
    ignore_changes = [route, propagating_vgws, tags]
  }
}

resource "aws_route_table_association" "this" {
  for_each       = local.route_table_associations
  route_table_id = aws_route_table.managed[each.value.rt].id
  subnet_id      = aws_subnet.this[each.value.subnet].id
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = local.vpc_endpoints

  vpc_id            = aws_vpc.this[each.value.vpc_name].id
  vpc_endpoint_type = "Gateway"

  service_name = format(
    "com.amazonaws.%s.%s",
    element(split(":", aws_vpc.this[each.value.vpc_name].arn), 3),
    each.value.service
  )

  route_table_ids = [
    for rt in each.value.route_tables :
    contains(keys(local.managed_route_tables), rt)
    ? aws_route_table.managed[rt].id
    : aws_route_table.imported[rt].id
  ]

  tags = each.value.tags
}
