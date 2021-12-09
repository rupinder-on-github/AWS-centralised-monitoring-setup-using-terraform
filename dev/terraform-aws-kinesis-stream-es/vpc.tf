locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.public_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length

}

resource aws_vpc "this" {
    count = var.create_vpc ? 1 : 0
    cidr_block = var.vpc_cidr
    instance_tenancy = var.instance_tenancy 
    tags_all = var.tags 
    tags = var.tags
    
}
### ------------------>>>>>>>>>>>>     FLOW LOGS 
resource "aws_flow_log" "this" {
    count = var.create_flow_log ? 1 : 0
    iam_role_arn = aws_iam_role.this[0].arn
    vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
    traffic_type = "ALL"
    log_destination = aws_cloudwatch_log_group.this[0].arn
}
resource "aws_cloudwatch_log_group" "this" {
    count = var.create_flow_log ? 1 : 0
    name = var.cloudwatch_log_group_name
  
}
resource "aws_iam_role" "this" {
    count = var.create_flow_log ? 1 : 0
    name = var.flow_logs_iam_role_name

      assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "this" {
  count = var.create_flow_log ? 1 : 0
  name = "aws_iam_role_policy_vpc_flowlogs"
  role = aws_iam_role.this[0].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
### ------------------>>>>>>>>>>>>     SUBNETS 
resource "aws_subnet" "private" {
    count = var.create_private_subnets ? length(var.private_subnets) : 0 
    vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
    cidr_block                      = var.private_subnets[count.index]
    availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
    availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
    tags = {
    Tier = "private_subnet"
    }
}
resource "aws_subnet" "public" {
  count = var.create_public_subnets ? length(var.public_subnets) : 0
  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block = element(concat(var.public_subnets, [""]), count.index)
  availability_zone  = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  tags = {
    Tier = "public_subnet"
  }
    
}
resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway && length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  
  
}

### ------------------>>>>>>>>>>>>    PUBLIC ROUTES 
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_internet_gateway  && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}
### ------------------>>>>>>>>>>>>     NAT-GATEWAY

locals {
  nat_gateway_ips = split(
    ",",
    var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.this.*.id),
  )
}

resource "aws_route_table" "private" {
  count = var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

}
resource "aws_eip" "this" {
  count = var.create_vpc && var.create_internet_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0
  vpc = true
  
}
resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.create_nat_gateway ? local.nat_gateway_count : 0
  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  depends_on = [aws_internet_gateway.this]  
}
resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.create_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}
