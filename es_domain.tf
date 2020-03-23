module "es" {
  source = "git::https://github.com/terraform-community-modules/tf_aws_elasticsearch.git?ref=v1.1.0"

  domain_name       = "mxmgny-elasticsearch"
  instance_count    = 2
  instance_type     = "m4.large.elasticsearch"
  es_zone_awareness = true
  ebs_volume_size   = 100
  management_public_ip_addresses = ["0.0.0.0/0"]
}
