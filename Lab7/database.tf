resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "aurora-cluster"
  engine = "aurora-postgresql"
  engine_version = "16.6"
  master_username = "username"
  master_password = "password"
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier = "aurora-instance"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class = "db.r6g.2xlarge"
  engine = aws_rds_cluster.aurora_cluster.engine
  engine_version = aws_rds_cluster.aurora_cluster.engine_version
}