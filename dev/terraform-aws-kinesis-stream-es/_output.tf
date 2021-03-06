output "kinesis_arn" {
  description = "The ARN of the kinesis firehose stream to be used in the cloudwatch log subscription filter."
  value       = "arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deliverystream/${var.kinesis_firehose_name}"
}
output "vpc_id" {
    value = aws_vpc.this.*.id
    }
output "private_subnets" {
    value = aws_subnet.private.*.id
}
