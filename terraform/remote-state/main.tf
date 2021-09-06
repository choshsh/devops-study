resource "aws_s3_bucket" "choshsh-remote-state" {
  bucket = "choshsh-remote-state"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Service     = "terraform"
  }
}
