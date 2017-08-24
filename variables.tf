variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "redshift_master_username" {
  type = "string"
}

variable "redshift_master_password" {
  type = "string"
}

variable "segment_redshift_node_type" {
  type = "string"
  default = "single-node"
}

variable "segment_redshift_number_of_nodes" {
  type = "string"
  default = "1"
}

variable "segment_user_password" {
  type = "string"
}
