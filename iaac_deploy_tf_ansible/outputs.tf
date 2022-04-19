output "Jenkins-Main-Node-Public-ip" {
  value = aws_instance.jenkins-master.public_ip

}

output "Jenkins-worker-Public-ip" {
  value = {
    for instance in aws_instance.jenkins-worker-oregon :
    instance.id => instance.public_ip
  }

}

output "LB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name

}