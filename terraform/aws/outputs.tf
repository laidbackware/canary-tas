locals {
  stable_config = {
    pas_subnet_ids = aws_subnet.pas-subnet[*].id
    pas_subnet_cidrs = aws_subnet.pas-subnet[*].cidr_block
    pas_subnet_gateways = [
      for i in range(length(var.availability_zones)) :
      cidrhost(aws_subnet.pas-subnet[i].cidr_block, 1)
    ]
    pas_subnet_reserved_ip_ranges = [
      for i in range(length(var.availability_zones)) :
      "${cidrhost(aws_subnet.pas-subnet[i].cidr_block, 1)}-${cidrhost(aws_subnet.pas-subnet[i].cidr_block, 9)}"
    ]

    buildpacks_bucket_name = aws_s3_bucket.buildpacks-bucket.bucket
    droplets_bucket_name = aws_s3_bucket.droplets-bucket.bucket
    packages_bucket_name = aws_s3_bucket.packages-bucket.bucket
    resources_bucket_name = aws_s3_bucket.resources-bucket.bucket
    tas_blobstore_iam_instance_profile_name = aws_iam_instance_profile.pas-blobstore.name

    ssh_lb_security_group_id = aws_security_group.ssh-lb.id
    ssh_lb_security_group_name = aws_security_group.ssh-lb.name
    ssh_target_group_name = aws_lb_target_group.ssh.name

    tcp_lb_security_group_id = aws_security_group.tcp-lb.id
    tcp_lb_security_group_name = aws_security_group.tcp-lb.name
    tcp_target_group_names = aws_lb_target_group.tcp[*].name

    web_lb_security_group_id = aws_security_group.web-lb.id
    web_lb_security_group_name = aws_security_group.web-lb.name
    web_target_group_names = [
      aws_lb_target_group.web-80.name,
      aws_lb_target_group.web-443.name]

    mysql_security_group_id = aws_security_group.mysql.id
    mysql_security_group_name = aws_security_group.mysql.name

    sys_dns_domain = replace(aws_route53_record.wildcard-sys.name, "*.", "")
    apps_dns_domain = replace(aws_route53_record.wildcard-apps.name, "*.", "")
    ssh_dns = aws_route53_record.ssh.name
    tcp_dns = aws_route53_record.tcp.name

    environment_name   = var.environment_name
    availability_zones = var.availability_zones
    region             = var.region

    vpc_id = aws_vpc.vpc.id

    public_subnet_ids   = aws_subnet.public-subnet[*].id
    public_subnet_cidrs = aws_subnet.public-subnet[*].cidr_block

    management_subnet_ids   = aws_subnet.management-subnet[*].id
    management_subnet_cidrs = aws_subnet.management-subnet[*].cidr_block
    management_subnet_gateways = [
      for i in range(length(var.availability_zones)) :
      cidrhost(aws_subnet.management-subnet[i].cidr_block, 1)
    ]
    management_subnet_reserved_ip_ranges = [
      for i in range(length(var.availability_zones)) :
      "${cidrhost(aws_subnet.management-subnet[i].cidr_block, 1)}-${cidrhost(aws_subnet.management-subnet[i].cidr_block, 9)}"
    ]

    ops_manager_subnet_id                 = aws_subnet.public-subnet[0].id
    ops_manager_public_ip                 = aws_eip.ops-manager.public_ip
    ops_manager_dns                       = aws_route53_record.ops-manager.name
    ops_manager_iam_user_access_key       = aws_iam_access_key.ops-manager.id
    ops_manager_iam_user_secret_key       = aws_iam_access_key.ops-manager.secret
    ops_manager_iam_instance_profile_name = aws_iam_instance_profile.ops-manager.name
    ops_manager_key_pair_name             = aws_key_pair.ops-manager.key_name
    ops_manager_ssh_public_key            = tls_private_key.ops-manager.public_key_openssh
    ops_manager_ssh_private_key           = tls_private_key.ops-manager.private_key_pem
    ops_manager_bucket                    = aws_s3_bucket.ops-manager-bucket.bucket
    ops_manager_security_group_id         = aws_security_group.ops-manager.id
    ops_manager_security_group_name       = aws_security_group.ops-manager.name

    platform_vms_security_group_id   = aws_security_group.platform.id
    platform_vms_security_group_name = aws_security_group.platform.name

    nat_security_group_id   = aws_security_group.nat.id
    nat_security_group_name = aws_security_group.nat.name

    services_subnet_ids   = aws_subnet.services-subnet[*].id
    services_subnet_cidrs = aws_subnet.services-subnet[*].cidr_block
    services_subnet_gateways = [
      for i in range(length(var.availability_zones)) :
      cidrhost(aws_subnet.services-subnet[i].cidr_block, 1)
    ]
    services_subnet_reserved_ip_ranges = [
      for i in range(length(var.availability_zones)) :
      "${cidrhost(aws_subnet.services-subnet[i].cidr_block, 1)}-${cidrhost(aws_subnet.services-subnet[i].cidr_block, 9)}"
    ]

    ssl_certificate = var.ssl_certificate
    ssl_private_key = var.ssl_private_key
  }
}

output "stable_config_yaml" {
  value = yamlencode(local.stable_config)
  sensitive = true
}
