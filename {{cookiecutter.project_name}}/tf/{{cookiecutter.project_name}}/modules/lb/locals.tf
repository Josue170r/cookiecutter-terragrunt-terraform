locals {
  target_groups_flat = merge([
    for lb_key, lb in var.load_balancers : {
      for tg_key, tg in lb.target_groups :
      "${tg_key}" => merge(tg, {
        lb_key = lb_key
      })
    }
  ]...)

  listeners_flat = merge([
    for lb_key, lb in var.load_balancers : {
      for ln_key, ln in lb.listeners :
      "${lb_key}-${ln_key}" => merge(ln, {
        lb_key      = lb_key
        tg_flat_key = ln.target_group_key != null ? "${ln.target_group_key}" : null
      })
    }
  ]...)

  attachments_flat = merge([
    for lb_key, lb in var.load_balancers : merge([
      for tg_key, tg in lb.target_groups : {
        for att_key, att in tg.attachments :
        "${tg_key}-${att_key}" => merge(att, {
          lb_key      = lb_key
          tg_flat_key = "${tg_key}"
          target_type = tg.target_type
        })
      }
    ]...)
  ]...)
}
