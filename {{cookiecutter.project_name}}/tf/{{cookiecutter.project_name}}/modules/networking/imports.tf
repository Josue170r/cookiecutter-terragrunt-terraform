import {
  for_each = { for k, v in var.vpcs : k => v.import_id if v.import_id != null }
  to       = aws_vpc.this[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in local.subnets : k => v.import_id if v.import_id != null }
  to       = aws_subnet.this[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in local.internet_gateways : k => v.import_id if v.import_id != null }
  to       = aws_internet_gateway.this[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in local.nat_gateways : k => v.eip_import_id if v.eip_import_id != null }
  to       = aws_eip.nat[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in local.nat_gateways : k => v.import_id if v.import_id != null }
  to       = aws_nat_gateway.this[each.key]
  id       = each.value
}

import {
  for_each = { for k, v in local.route_tables : k => v.import_id if v.import_id != null }
  to       = aws_route_table.imported[each.key]
  id       = each.value
}
