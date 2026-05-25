output "sns_topic_arn"{
    description = "ARN of operational alearts SNS topic"
    value = aws_sns_topic.operational_alerts.arn
}
output "sns_topic_name" {
  description = "name of operational alerts SNS topic"
  value = aws_sns_topic.operational_alerts.name

}