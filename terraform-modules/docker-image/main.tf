// Create IAM role to manage elasticbeanstalk
resource "aws_iam_role_policy_attachment" "default" {
	// TODO: Restrict this policy
	policy_arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
	role = aws_iam_role.default.name
}
resource "aws_iam_role" "default" {
	assume_role_policy = <<EOF
{
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Effect": "Allow",
			"Principal": {
				"Service": "ec2.amazonaws.com"
			},
			"Sid": ""
		}
	],
	"Version": "2012-10-17"
}
EOF
}
resource "aws_iam_instance_profile" "default" {
	role = aws_iam_role.default.name
}

// Create environment
resource "random_id" "default" {
	byte_length = 40
}
resource "aws_elastic_beanstalk_application" "default" {
	name = random_id.default.b64_url
}

// Create release
resource "aws_s3_bucket" "default" {
}
resource "aws_s3_bucket_object" "authentication" {
	bucket = aws_s3_bucket.default.id
	key = "docker-config.json"
	content = jsonencode({
		auths = {
			(split("/", var.image)[0]) = {
				"password" = var.registry_password
				"username" = var.registry_username
			}
		}
	})
}
resource "aws_s3_bucket_object" "default" {
	bucket = aws_s3_bucket.default.id
	key = "Dockerrun.aws.json"
	content = jsonencode({
		"AWSEBDockerrunVersion" = "1"
		"Authentication" = {
			"Bucket" = aws_s3_bucket.default.id
			"Key" = aws_s3_bucket_object.authentication.id
		}
		"Image" = {
			"Name" = var.image
			"Update" = "true"
		}
		"Ports" = [
			{ "ContainerPort" = var.port }
		]
	})
	content_type = "application/json"
}
resource "time_sleep" "wait_for_s3_object" {
	create_duration = "3s"
	depends_on = [
		aws_s3_bucket_object.authentication,
		aws_s3_bucket_object.default,
	]
}
resource "aws_elastic_beanstalk_application_version" "default" {
	application = aws_elastic_beanstalk_application.default.name
	bucket = aws_s3_bucket.default.id
	key = "Dockerrun.aws.json"
	// For display purposes, get last 100 characters for version label
	name = strrev(substr(strrev(replace("${var.image}", "/", "\\")), 0, 100))

	depends_on = [time_sleep.wait_for_s3_object]
}

// Create Application
resource "aws_elastic_beanstalk_environment" "default" {
	application = aws_elastic_beanstalk_application.default.name
	name = var.name
	solution_stack_name = "64bit Amazon Linux 2 v3.1.1 running Docker"
	tier = var.type == "website" ? "WebServer" : "Worker"
	version_label = aws_elastic_beanstalk_application_version.default.id

	setting {
		name = "IamInstanceProfile"
		namespace = "aws:autoscaling:launchconfiguration"
		value = aws_iam_instance_profile.default.name
	}
	setting {
		name = "InstanceTypes"
		namespace = "aws:ec2:instances"
		value = "t3.micro"
	}
	setting {
		name = "MaxSize"
		namespace = "aws:autoscaling:asg"
		value = var.max
	}
	setting {
		name = "MinSize"
		namespace = "aws:autoscaling:asg"
		value = var.min
	}
	setting {
		name = "RollingUpdateType"
		namespace = "aws:autoscaling:updatepolicy:rollingupdate"
		value = "Immutable"
	}

	// Environmental settings
	dynamic "setting" {
		for_each = var.environment
		content {
			name = setting.value["key"]
			namespace = "aws:elasticbeanstalk:application:environment"
			value = setting.value["value"]
		}
	}
}
