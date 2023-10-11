resource "aws_iam_user" "mento" {
  name = "mento"
}

resource "aws_iam_policy" "mento_policy" {
  name = "mento-policy"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "mento_policy_attachment" {
  name       = "mento-policy-attachment"
  users      = [aws_iam_user.mento.name]
  policy_arn = aws_iam_policy.mento_policy.arn
}
