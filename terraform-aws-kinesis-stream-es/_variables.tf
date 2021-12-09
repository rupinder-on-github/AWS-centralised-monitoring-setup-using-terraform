variable "elasticsearch_enabled" {
  description = "If true, will create aws elasticsearch domain."
  default     = true
  type        = bool
}
#variable "private_subnet_ids" { 
#  type = list 
#  description = "(optional) describe your variable"
#}

variable "elasticsearch_name" {
  description = "The name of the Elasticsearch domain."
  type        = string
}

variable "elasticsearch_instance_type" {
  description = "(Optional) Instance type of data nodes in the cluster."
  default     = "r5.large.elasticsearch"
  type        = string
}

variable "elasticsearch_instance_count" {
  description = "(Optional) Number of instances in the cluster."
  default     = 3
  type        = number
}

variable "elasticsearch_version" {
  description = "(Optional) The version of Elasticsearch to deploy. Defaults to 7.4"
  default     = "7.4"
  type        = string
}

variable "elasticsearch_zone_awareness_enabled" {
  description = "(Optional) Indicates whether zone awareness is enabled, set to true for multi-az deployment. To enable awareness with three Availability Zones, the availability_zone_count within the zone_awareness_config must be set to 3."
  default     = true
  type        = bool
}

variable "elasticsearch_dedicated_master_enabled" {
  description = "(Optional) Indicates whether dedicated master nodes are enabled for the cluster."
  default     = false
  type        = bool
}

variable "elasticsearch_dedicated_master_count" {
  description = "(Optional) Number of dedicated master nodes in the cluster."
  default     = 3
  type        = number
}

variable "elasticsearch_dedicated_master_type" {
  description = "(Optional) Instance type of the dedicated master nodes in the cluster."
  default     = "m4.large.elasticsearch"
  type        = string
}

variable "elasticsearch_availability_zone_count" {
  description = "(Optional) Number of Availability Zones for the domain to use with zone_awareness_enabled. Valid values: 2 or 3."
  default     = 3
  type        = number
}

variable "elasticsearch_encrypt_at_rest" {
  description = "(Optional) Encrypt at rest options. Only available for certain instance types."
  default     = true
  type        = bool
}

variable "elasticsearch_node_to_node_encryption" {
  description = "(Optional) Node-to-node encryption options."
  default     = true
  type        = bool
}

variable "elasticsearch_volume_type" {
  description = "(Optional) The type of EBS volumes attached to data nodes."
  default     = "gp2"
  type        = string
}

variable "elasticsearch_volume_size" {
  description = "The size of EBS volumes attached to data nodes (in GB). Required if ebs_enabled is set to true."
  default     = 10
  type        = number
}

variable "firehose_lambda_processor_name" {
  default = "firehose_lambda_processor"
  type    = string
}

variable "kinesis_firehose_enabled" {
  description = "If true, will create the AWS kinesis firehose."
  default     = true
  type        = bool
}

variable "kinesis_firehose_name" {
  description = "(Required) A name to identify the stream. This is unique to the AWS account and region the Stream is created in."
  default     = "kinesis-firehose-es-stream"
  type        = string
}

variable "kinesis_firehose_index_name" {
  description = "(Required) The Elasticsearch index name."
  default     = "kinesis"
  type        = string
}

variable "kinesis_firehose_index_rotation_period" {
  default     = "OneDay"
  type        = string
  description = "(Optional) The Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data. Valid values are NoRotation, OneHour, OneDay, OneWeek, and OneMonth. The default value is OneDay."
}

variable "kinesis_stream_bucket_name" {
  description = "The name of the S3 bucket to store failed documents."
  default     = "kinesis-logs-stream-backup-bucket"
  type        = string
}
variable "create_vpc" {
    type = bool
    default = false
}
variable "single_nat_gateway" {
    type = bool
    default = false  
}
variable "one_nat_gateway_per_az" {
    type = bool
    default = true
  
}
variable "reuse_nat_ips" {
    type = bool
    default = false
}
variable "private_subnets" {
    type = list
    default = []
}
variable "public_subnets" {
    type = list
    default = []
}
variable "public_subnet_suffix" {
    type = string
    description = "optional"
    default = "Opensearch"
}
variable "name" {
    type = string
    default = "opensearch"
}
variable "external_nat_ip_ids" {
    type = list
    default = []
}
variable "azs" {
    type = list
    default = ["us-east-1a","us-east-1b","us-east-1c"]
}
variable "create_private_subnets" {
    type = bool
    default = true  
}
variable "create_public_subnets" {
    type = bool
    default = true  
}
variable "public_route_table_tags" {
    type = map
    description = "(optional)"
    default = {
        name = "Public route table"
    }
}
variable "create_internet_gateway" {
    type = bool
    default = false
}
variable "create_nat_gateway" {
    type = bool
    default = false
}
variable "enable_flow_logs" {
    type = bool
    default = true
  
}
variable "vpc_id" {
    type = string
    description = "VPC ID"
}
variable "vpc_cidr" {
    type = string 
    default = "10.1.1.0/24"  
}
variable "instance_tenancy" {
    type = string
    default = "default"
}
variable "enable_dns_support" {  
    type = bool
    default = false
}

variable "enable_dns_hostnames" {  
    type = bool
    default = false
}
variable "tags" {
   type = map
   default = {
       name = "opensearch_domain_vpc"
       team = "UNO"
   }
}
variable "cloudwatch_log_group_name" {
    type = string
    default = "opensearch-vpc-flow-logs"  
}
variable "flow_logs_iam_role_name" {
    type = string
    default = "opensearch_flow_logs_iam_role_name"
  
}
variable "create_flow_log" {
    type = bool
    default = false
  
}
variable "aws_kinesis_shard_count" {
  type = number
  default= 3
}
variable "aws_kinesis_retention_period" {
  type = number
  default = 48
}
variable "aws_kinesis_stream_enable_encrytion" {
  type = string
  default = "NONE"
}
variable "aws_kinesis_stream_kms_key_id" {
  type = string
  default = " "
}
variable "root_path" {
  type = bool
  default = false
}
variable "kinesis_firehose_stream_backup_prefix" {
  type = string
  default = "/backup"
}
variable "aws_kinesis_stream_name" {
  type = string
  default = "centralised_log_monitoring_stream"
}
variable "create_aws_kinesis_stream" {
  type = bool
  default = true
}