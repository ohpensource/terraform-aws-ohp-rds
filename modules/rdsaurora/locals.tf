locals {
  port                 = var.port == "" ? (var.engine == "aurora-postgresql" ? 5432 : 3306) : var.port
  db_subnet_group_name = var.db_subnet_group_name == "" ? join("", aws_db_subnet_group.this.*.name) : var.db_subnet_group_name
  master_password      = var.create_cluster && var.create_random_password && var.is_primary_cluster ? random_password.master_password[0].result : var.password
  backtrack_window     = (var.engine == "aurora-mysql" || var.engine == "aurora") && var.engine_mode != "serverless" ? var.backtrack_window : 0

  rds_enhanced_monitoring_arn = var.create_monitoring_role ? join("", aws_iam_role.rds_enhanced_monitoring.*.arn) : var.monitoring_role_arn
  rds_security_group_id       = join("", aws_security_group.this.*.id)

  # TODO - remove coalesce() at next breaking change - adding existing name as fallback to maintain backwards compatibility
  iam_role_name        = var.iam_role_use_name_prefix ? null : coalesce(var.iam_role_name, "rds-enhanced-monitoring-${var.name}")
  iam_role_name_prefix = var.iam_role_use_name_prefix ? "${var.iam_role_name}-" : null

  name = "aurora-${var.name}"
}