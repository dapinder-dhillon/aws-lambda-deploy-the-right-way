locals {
  common_tags = {
    product       = var.tag_product
    subproduct    = var.tag_sub_product
    environment   = var.environment
    orchestration = var.tag_orchestration
    costcode      = var.tag_costcode
    contact       = var.tag_contact
  }
}
