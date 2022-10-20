# resource "aws_iam_role" "this" {
#   name = "ecsTaskExecutionRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_policy" "this" {
#   name = "MyCloudWatchAccess"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [ 
#           "logs:*" 
#           ],
#         Effect = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "a1" {
#   role       = aws_iam_role.this.name
#   policy_arn = aws_iam_policy.this.arn
# }