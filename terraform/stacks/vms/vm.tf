module "node_one" {
  source = "./vm"
  device_name = "node-one"
  email = var.email
  subnetwork = var.subnetwork 
}

module "node_two" {
  source = "./vm"
  device_name = "node-two"
  email = var.email
  subnetwork = var.subnetwork
}
