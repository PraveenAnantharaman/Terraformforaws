provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAJFTQD2AJV2TJOCMA"
  secret_key = "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"
}

# Public Subnet
resource "aws_subnet" "Udacity_Public_Subnet" {
  vpc_id = "vpc-03d90970e51e7d0f8"
  cidr_block = "10.1.10.0/24"
  availability_zone = "us-east-1a"
  tags = {
      Name = "terraform_public_subnet"
  }
}
output "public_subnet_id" {
  value = "subnet-062ae0ec67b1d0745"
}
resource "aws_instance" "Udacity_T2" { 
  count = "1"
  ami           = "ami-0947d2ba12ee1ff75"
  instance_type = "t2.micro"
}
resource "aws_instance" "Udacity_M4" {
  count = "0"
  ami = "ami-0947d2ba12ee1ff75"
  instance_type = "m4.large"
  tags = {
    name = "Udacity Terraform"
  }
}
resource "aws_route_table" "Udacity_Public_Routes" {
  vpc_id = "vpc-03d90970e51e7d0f8"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "igw-065c15cbf97da4d97"
  }
  tags = {
      Name = "Udacity"
  }
}

resource "aws_route_table_association" "Udacity_Public_Routes" {
  subnet_id = "subnet-062ae0ec67b1d0745"
  route_table_id = "rtb-0d9739bc2703187e9"
}
		resource "aws_lambda_function" "lambda" {
		   function_name = "ServerlessExample"
		   # The bucket name as created earlier with "aws s3api create-bucket"
		   s3_bucket = "projterraform"
		   s3_key    = "v1.0.0/lambda.zip"
		   # "lambda" is the filename within the zip file (lambda.py) and "handler"
		   # is the name of the property under which the handler function was
		   # exported in that file.
		   handler = "lambda_handler"
		   runtime = "python3.6"
		   role = aws_iam_role.lambda_exec.arn
		   depends_on = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.example"]
		 }
		resource "aws_iam_role" "iam_for_lambda" {
		  name = "iam_for_lambda"
		  assume_role_policy = <<EOF
		{
		  "Version": "2012-10-17",
		  "Statement": [
		    {
		      "Action": "sts:AssumeRole",
		      "Principal": {
		        "Service": "lambda.amazonaws.com"
		      },
		      "Effect": "Allow",
		      "Sid": ""
		    }
		  ]
		}
		EOF
		}
		#IAM role which dictates what other AWS services the Lambda function
		# may access.
		resource "aws_iam_role" "lambda_exec" {
		    name = "serverless_example_lambda"
		    assume_role_policy = <<EOF
		{
		   "Version": "2012-10-17",
		   "Statement": [
		     {
		       "Action": "sts:AssumeRole",
		       "Principal": {
		         "Service": "lambda.amazonaws.com"
		       },
		       "Effect": "Allow",
		       "Sid": ""
		     }
		   ]
		 }
		 EOF
		}
		resource "aws_lambda_function" "test_lambda" {
		   function_name = "ServerlessTest"
		  # The bucket name as created earlier with "aws s3api create-bucket"
		   s3_bucket = "projterraform"
		   s3_key    = "v1.0.0/lambda.zip"
		  
		  handler = "lambda_handler"
		  runtime = "python3.6"
		  # ... other configuration ...
		  role = aws_iam_role.lambda_exec.arn
		  depends_on = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.example"]
		}
		# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
		# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
		resource "aws_cloudwatch_log_group" "example" {
		  name = "/aws/lambda/lambda_handler"
		  retention_in_days = 14
		}
		
		# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
		resource "aws_iam_policy" "lambda_logging" {
		  name        = "lambda_logging"
		  path        = "/"
		  description = "IAM policy for logging from a lambda"
		  policy = <<EOF
		{
		  "Version": "2012-10-17",
		  "Statement": [
		    {
		      "Action": [
		        "logs:CreateLogGroup",
		        "logs:CreateLogStream",
		        "logs:PutLogEvents"
		      ],
		      "Resource": "arn:aws:logs:*:*:*",
		      "Effect": "Allow"
		    }
		  ]
		}
		EOF
		}
		resource "aws_iam_role_policy_attachment" "lambda_logs" {
		  role       = "${aws_iam_role.iam_for_lambda.name}"
		  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
		}
