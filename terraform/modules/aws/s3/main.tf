########## S3_Bucket ##########
resource "aws_s3_bucket" "s3_bucket" {
  for_each                          = toset(var.create_bucket_list)
  bucket                            = each.value
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket" {
  for_each                          = toset(var.create_bucket_list)
  bucket                            = aws_s3_bucket.s3_bucket[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

data "aws_iam_policy_document" "s3_bucket" {
  for_each                          = toset(var.create_bucket_list)

  statement {
    sid                             = "AllowSSLRequestsOnly"
    effect                          = "Deny"

    principals {
      type                          = "*"
      identifiers                   = [ "*" ]
    }

    actions                         = [ "s3:*" ]
    resources                       = [
                                        aws_s3_bucket.s3_bucket[each.key].arn,
                                        "${aws_s3_bucket.s3_bucket[each.key].arn}/*"
                                      ]

    condition {
      test                          = "Bool"
      variable                      = "aws:SecureTransport"
      values                        = [ "false" ]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  for_each                          = toset(var.create_bucket_list)

  bucket                            = aws_s3_bucket.s3_bucket[each.key].id
  policy                            = data.aws_iam_policy_document.s3_bucket[each.key].json
}