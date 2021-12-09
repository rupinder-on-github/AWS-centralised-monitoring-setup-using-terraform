module "aws_es" {

  source = "lgallard/elasticsearch/aws"

  domain_name           = var.es_domain_name
  elasticsearch_version = var.es_version

  cluster_config = {
    dedicated_master_enabled = true
    instance_count           = 3
    instance_type            = "r5.large.elasticsearch"
    zone_awareness_enabled   = true
    availability_zone_count  = 3
  }

  ebs_options = {
    ebs_enabled = true
    volume_size = 25
  }

  encrypt_at_rest = {
    enabled    = true
    kms_key_id = "arn:aws:kms:us-east-1:753813044468:key/7bf7caee-4783-4996-a483-0c11993c58d7"
  }

  vpc_options = {
    subnet_ids         = ["subnet-0386627ec4d08a2cb", "subnet-0bb8eab2bb8098cad", "subnet-0d713f18e2e802377"]
    security_group_ids = ["sg-0550866d831625b7a"]
  }

  node_to_node_encryption_enabled                = true
  snapshot_options_automated_snapshot_start_hour = 23

  access_policies = templatefile("${path.module}/access_policies.tpl", {
    region      = data.aws_region.current.name,
    account     = data.aws_caller_identity.current.account_id,
    domain_name = var.es_domain_name
  })

  timeouts_update = "60m"

  tags = {
    Owner = "sysops"
    env   = "dev"
  }
}
