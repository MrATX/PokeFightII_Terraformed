output "app_url" {
  value = "${aws_instance.pf2instance.public_ip}:5000"
}