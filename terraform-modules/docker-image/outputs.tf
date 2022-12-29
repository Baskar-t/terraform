output "cname" {
	value = aws_elastic_beanstalk_environment.default.cname
}
output "url" {
	value = aws_elastic_beanstalk_environment.default.endpoint_url
}
