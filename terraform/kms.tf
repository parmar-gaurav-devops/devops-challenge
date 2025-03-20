resource "aws_kms_key" "db_kms_key" {
  description             = "KMS key for encrypting DB credentials"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "db_kms_alias" {
  name          = "alias/db-kms-key"
  target_key_id = aws_kms_key.db_kms_key.key_id
}


resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "ruby-app-db-secret"
  kms_key_id              = aws_kms_key.db_kms_key.arn
  recovery_window_in_days = 7
}


