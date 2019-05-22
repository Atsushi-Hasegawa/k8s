variable "project" {}
variable "cluster_name" {}
variable "kubernetes" {
  type = "map"
}
variable "depends_on" {
  type = "list"
  default = []
}
