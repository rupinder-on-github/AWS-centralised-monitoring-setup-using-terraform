resource "aws_kinesis_stream" "this" {
  count = var.create_aws_kinesis_stream ? 1 : 0
  name             = var.aws_kinesis_stream_name
  shard_count      = var.aws_kinesis_shard_count
  retention_period = var.aws_kinesis_retention_period 
  encryption_type  = var.aws_kinesis_stream_enable_encrytion 
  kms_key_id = var.aws_kinesis_stream_kms_key_id

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "test"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "this" {
  depends_on = [aws_iam_role_policy.firehose_es_stream_policy]

  name        = var.kinesis_firehose_name
  destination = "elasticsearch"
  
  s3_configuration {
    role_arn   = aws_iam_role.firehose_es_stream_role[0].arn
    bucket_arn = aws_s3_bucket.bucket.arn
    prefix     = var.kinesis_firehose_stream_backup_prefix
  
    cloudwatch_logging_options {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
        log_stream_name = aws_cloudwatch_log_stream.kinesis_firehose_stream_logging_stream.name
      }
    }
  kinesis_source_configuration{
       kinesis_stream_arn  = aws_kinesis_stream.this[0].arn
       role_arn = aws_iam_role.firehose_es_stream_role[0].arn
   }
  elasticsearch_configuration {
    domain_arn = aws_elasticsearch_domain.es[0].arn
    role_arn   = aws_iam_role.firehose_es_stream_role[0].arn
    index_name = var.kinesis_firehose_index_name
    vpc_config {
      subnet_ids         = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]
      security_group_ids = [aws_security_group.kdf_sec_grp.id]
      role_arn           =  aws_iam_role.firehose_es_stream_role[0].arn
    }
    
  
    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }
  }
}
  
resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  name = "/aws/kinesisfirehose/${var.kinesis_firehose_name}"
}

resource "aws_cloudwatch_log_stream" "kinesis_firehose_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "S3Delivery"
}
locals {
  path_prefix = "${var.root_path ? path.root : path.module}/firehose_lambda_processor"
}

