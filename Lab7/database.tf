resource "aws_rds_cluster" "aurora_cluster" {
    engine = "aurora-postgresql"
    engine_version = "16.6"
    database_name = "nixacpg"
    db_subnet_group_name = aws_db_subnet_group.pg_subnet_group.name
    vpc_security_group_ids = [aws_security_group.pg_security_group.id]
    master_username = "username"
    master_password = "password"
    skip_final_snapshot=true
    apply_immediately = true
}

resource "aws_rds_cluster_instance" "aurora_instance" {
    cluster_identifier = aws_rds_cluster.aurora_cluster.id
    instance_class = "db.t3.medium"
    engine = aws_rds_cluster.aurora_cluster.engine
    engine_version = aws_rds_cluster.aurora_cluster.engine_version
    publicly_accessible = true
}