variable "name" {
    type = string
    default = "kinesis-stream-test"
}
variable "shard_count" {
    type = string
    default = "1"  
}
variable "retention_period" {
    type = string
    default = "48"
  
}
variable "shard_level_metrics" {
    type = list
    default = ["IncomingBytes","OutgoingBytes"] 
}
variable "tags" {
    type = map
    default = {
        env = "test"
    }
}
variable "encryption_type" {
        type = string
        default = "NONE"
    }

variable "kms_key_id" {
    type = string
    default = "alias/aws/kinesis"
}
