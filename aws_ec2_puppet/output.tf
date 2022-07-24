output "master_ip" {
  value = aws_instance.master.public_ip
}

# output "agent_ip" {
#   value = aws_instance.agent.public_ip
# }