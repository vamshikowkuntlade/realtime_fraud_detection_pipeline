locals {
    sns_topic_name = "${var.project_name}-${var.environment}-operational-alerts"
}

resource "aws_sns_topic" "operational_alerts" {
  name = local.sns_topic_name
  tags = var.tags
}


resource "aws_sns_topic_subscription" "email_alert_subscription" {
  topic_arn = aws_sns_topic.operational_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
