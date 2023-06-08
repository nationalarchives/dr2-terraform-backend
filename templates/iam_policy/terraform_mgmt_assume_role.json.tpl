{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${intg_role_arn}",
        "${staging_role_arn}",
        "${prod_role_arn}"
      ]
    }
  ]
}
