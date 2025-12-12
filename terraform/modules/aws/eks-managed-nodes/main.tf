########## Locals ##########
locals {
  launch_prefix                     = join("-", [ var.project_name, var.project_env ])
  user_data_tpl                     = "../../../../../../config/aws/common/template/eks_node.tpl"
  tags                              = merge(var.common_tags,
                                      {
                                        EKSCluster = var.cluster_name
                                      })
}

resource "random_id" "random" {
  byte_length                       = 2
}

########## KMS ##########
resource "aws_kms_key" "eks_node_kms" {
  description                       = "KMS key for encrypt/decrypt operations"
  deletion_window_in_days           = 10
  enable_key_rotation               = false
}

resource "aws_kms_alias" "eks_node_kms" {
  name                              = "alias/${local.launch_prefix}-eks-node-${random_id.random.hex}"
  target_key_id                     = aws_kms_key.eks_node_kms.key_id
}

data "aws_iam_policy_document" "eks_node_kms" {
  statement {
    effect                          = "Allow"
    resources                       = [ aws_kms_key.eks_node_kms.arn ]
    actions                         = [ "kms:*" ]

    principals {
      type                          = "AWS"
      identifiers                   = [ "arn:aws:iam::${var.aws_account_id}:root" ]
    }
  }

  statement {
    effect                          = "Allow"
    resources                       = [ aws_kms_key.eks_node_kms.arn ]
    actions                         = [
                                        "kms:Encrypt",
                                        "kms:Decrypt",
                                        "kms:GenerateDataKey*",
                                        "kms:ReEncrypt*",
                                        "kms:DescribeKey"
                                      ]

    principals {
      type                          = "AWS"
      identifiers                   = [ "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling" ]
    }

    condition {
      test                          = "StringEquals"
      variable                      = "kms:CallerAccount"
      values                        = [ "${var.aws_account_id}" ] 
    }
  }

  statement {
    effect                          = "Allow"
    resources                       = [ aws_kms_key.eks_node_kms.arn ]
    actions                         = [
                                        "kms:CreateGrant"
                                      ]

    principals {
      type                          = "AWS"
      identifiers                   = [ "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling" ]
    }

    condition {
      test                          = "StringEquals"
      variable                      = "kms:CallerAccount"
      values                        = [ "${var.aws_account_id}" ] 
    }

    condition {
      test                          = "Bool"
      variable                      = "kms:GrantIsForAWSResource"
      values                        = [ true ] 
    }
  }

  statement {
    effect                          = "Allow"
    resources                       = [ aws_kms_key.eks_node_kms.arn ]
    actions                         = [
                                        "kms:Encrypt",
                                        "kms:Decrypt",
                                        "kms:ReEncrypt*",
                                        "kms:GenerateDataKey*",
                                        "kms:CreateGrant",
                                        "kms:DescribeKey"
                                      ]

    principals {
      type                          = "AWS"
      identifiers                   = [ "*" ]
    }

    condition {
      test                          = "StringEquals"
      variable                      = "kms:CallerAccount"
      values                        = [ "${var.aws_account_id}" ] 
    }

    condition {
      test                          = "StringEquals"
      variable                      = "kms:ViaService"
      values                        = [ "ec2.${var.region}.amazonaws.com" ] 
    }
  }
}

resource "aws_kms_key_policy" "eks_node_kms" {
  key_id                            = aws_kms_key.eks_node_kms.key_id
  policy                            = data.aws_iam_policy_document.eks_node_kms.json
}

########## EKS_Managed_NodeGroup ##########
module "eks_managed_node_group" {
  for_each                          = { for nodes in var.managed_nodes_properties : nodes.name => nodes }

  source                            = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version                           = "21.1.0"

  create_launch_template            = true
  use_custom_launch_template        = true
  ebs_optimized                     = false
  enable_monitoring                 = true
  launch_template_use_name_prefix   = false
  launch_template_name              = "${local.launch_prefix}-${each.value.name}"
  name                              = "${each.value.name}-${replace(lower(each.value.eks_node_capacity_type), "_", "-")}"
  kubernetes_version                = var.eks_cluster_version
  subnet_ids                        = var.private_subnet_ids
  min_size                          = each.value.eks_node_min_size
  desired_size                      = each.value.eks_node_min_size
  max_size                          = each.value.eks_node_max_size
  capacity_type                     = each.value.eks_node_capacity_type
  instance_types                    = [ each.value.eks_node_instance_type ]
  ami_id                            = each.value.eks_node_ami_id
  ami_type                          = each.value.eks_node_ami_type
  cluster_primary_security_group_id = var.eks_cluster_primary_sg_id
  vpc_security_group_ids            = [ var.eks_nodegroup_sg_id ]
  update_config                     = {
                                        max_unavailable_percentage = 33
                                      }
  metadata_options                  = {
                                        http_endpoint               = "enabled"
                                        http_tokens                 = "required"
                                        http_put_response_hop_limit = 5
                                        instance_metadata_tags      = "enabled"
                                      }
  network_interfaces                = [{
                                        associate_public_ip_address = false
                                        delete_on_termination       = true
                                      }]
  enable_bootstrap_user_data        = each.value.enable_bootstrap_user_data
  user_data_template_path           = local.user_data_tpl
  cluster_name                      = var.cluster_name
  cluster_service_cidr              = var.eks_cluster_service_cidr
  cluster_endpoint                  = var.eks_cluster_endpoint
  cluster_auth_base64               = var.eks_cluster_ca_data
  block_device_mappings             = {
                                        "root" = {
                                          device_name                 = each.value.eks_node_block_device_name
                                          ebs = {
                                            volume_size               = each.value.eks_node_block_device_size
                                            volume_type               = "gp3"
                                            delete_on_termination     = true
                                            encrypted                 = true
                                            kms_key_id                = aws_kms_key.eks_node_kms.arn
                                          }
                                        }
                                      }
  iam_role_attach_cni_policy        = true
  iam_role_additional_policies      = {
                                        cloudwatch      = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
                                        cloudWatchLogs  = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
                                        ebscsi          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
                                      }
  tags                              = merge({NodeType = "${each.value.name}"}, local.tags)
  labels                            = {
                                        "kube/nodegroup"        = "${each.value.name}"
                                        "kube/nodetype"         = "${each.value.name}-${replace(lower(each.value.eks_node_capacity_type), "_", "-")}"
                                        "kube/project_env"      = "${var.project_env}"
                                        "kube/project_name"     = "${var.project_name}"
                                      }
  tag_specifications                = [ "instance", "volume", "network-interface" ]
  launch_template_tags              = merge(local.tags,
                                      {
                                        Name = "${local.launch_prefix}-eks-${each.value.name}"
                                      })
}