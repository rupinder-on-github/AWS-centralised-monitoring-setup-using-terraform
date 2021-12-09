
module "centralised_log_monitoring" {
    source = "../terraform-aws-kinesis-stream-es"
    create_vpc = true
    single_nat_gateway = false
    one_nat_gateway_per_az  = true
    private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
    public_subnets = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
    name = "Opensearch-vpc-route-tables"
    reuse_nat_ips = false
    external_nat_ip_ids  = []
    azs = ["us-east-1a","us-east-1b","us-east-1c"]
    create_private_subnets = true
    create_public_subnets = true
    create_internet_gateway = true
    create_nat_gateway  = true 
    enable_flow_logs  = true 
    vpc_id = ""
    vpc_cidr = "10.10.0.0/16"
    instance_tenancy = "default"
    enable_dns_support  = true
    enable_dns_hostnames = true 
    tags = {
     name = "demo"
     region = "nv"
     }
    cloudwatch_log_group_name = "opensearch_vpc__log_group"
    flow_logs_iam_role_name = "opensearch_vpc_role"
    create_flow_log = true
    public_subnet_suffix = "Openshift"
    public_route_table_tags = {
        name = "public_sunet"
        region = "nv"
    }
    elasticsearch_enabled = true
    elasticsearch_name   = "demo"
    elasticsearch_instance_type = "m6g.xlarge.elasticsearch"
    elasticsearch_instance_count = 3 
    elasticsearch_version = "OpenSearch_1.0"
    elasticsearch_zone_awareness_enabled = true
    elasticsearch_dedicated_master_enabled = false
    elasticsearch_dedicated_master_count = 0
    elasticsearch_dedicated_master_type = ""
    elasticsearch_availability_zone_count = 3
    elasticsearch_encrypt_at_rest = false
    elasticsearch_node_to_node_encryption = false
    elasticsearch_volume_type = "gp2"
    elasticsearch_volume_size = 32
    firehose_lambda_processor_name = "firehose_lambda_processor"
    kinesis_firehose_enabled = true
    kinesis_firehose_name  = "demofs"
    kinesis_firehose_index_name = "demofs"
    kinesis_firehose_index_rotation_period = "OneDay"
    kinesis_stream_bucket_name = "mybucket-28211400"

}

    

