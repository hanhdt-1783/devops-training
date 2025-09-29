resource "aws_secretsmanager_secret" "social_tokens" {
  name = "${var.project}-${var.env}-social-tokens"
}
