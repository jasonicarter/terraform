# Define provider
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-east-1"
}

# VPC
resource "aws_security_group" "segment_global_warehouse_security_group" {
  name        = "office_ip"
  description = "Allow all inbound traffic"

  # office and home
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["66.207.203.61/32", "205.175.213.40/32"]
  }

  # Segment
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["52.25.130.38/32"]
  }
}

# Create Redshift cluster for segment warehouse
resource "aws_redshift_cluster" "segment_warehouse" {
  cluster_identifier = "segement-terraform-dev"
  node_type = "dc1.large"
  master_username = "${var.redshift_master_username}"
  master_password = "${var.redshift_master_password}"
  final_snapshot_identifier = "some-snap"
  skip_final_snapshot = true
  database_name = "segment_dev_db"
  cluster_type = "${var.segment_redshift_node_type}"
  number_of_nodes = "${var.segment_redshift_number_of_nodes}"
  vpc_security_group_ids = ["${aws_security_group.segment_global_warehouse_security_group.id}"]

  provisioner "local-exec" {
    command = <<EOF
      PGPASSWORD='${aws_redshift_cluster.segment_warehouse.master_password}' \
      psql -h ${replace(aws_redshift_cluster.segment_warehouse.endpoint, ":5439", "")} \
        -U ${aws_redshift_cluster.segment_warehouse.master_username} \
        -d ${aws_redshift_cluster.segment_warehouse.database_name} \
        -p 5439 \
        -c "CREATE USER segment PASSWORD '${var.segment_user_password}'; GRANT CREATE ON DATABASE ${aws_redshift_cluster.segment_warehouse.database_name} TO segment;"
      EOF
  }
}

# Output to CLI
output "Segment Redshift endpoint" {
  value = "${replace(aws_redshift_cluster.segment_warehouse.endpoint, ":5439", "")}"
}
