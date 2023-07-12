resource "aws_security_group" "allow_everything_from_my_ip" {
  name        = "allow_everything_from_my_ip"
  description = "Allow everything from my IP"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "Allow everything from my IP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.myip}/32"]
  }
  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_runners_to_port_80" {
  name        = "allow_runners_to_port_80"
  description = "Allow runners to port 80"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "Allow everything from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["10.0.1.0/24"]
  }
}
