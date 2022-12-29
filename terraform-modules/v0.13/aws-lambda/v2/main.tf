locals {
	lambda_zip = "${var.source_directory}/terraform_${var.name}.zip"
}

data "archive_file" "default" {
	excludes = concat(["terraform_${var.name}.zip"], var.excluded_files)
	output_path = local.lambda_zip
	source_dir = var.source_directory
	type = "zip"
}
data "aws_iam_policy_document" "default" {
	version = "2012-10-17"

	statement {
		actions = ["sts:AssumeRole"]
		effect = "Allow"

		principals {
			identifiers = ["lambda.amazonaws.com"]
			type = "Service"
		}
	}
}
resource "aws_iam_role" "default" {
	assume_role_policy = data.aws_iam_policy_document.default.json
}
resource "aws_iam_role_policy_attachment" "default" {
	policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
	role = aws_iam_role.default.name
}
resource "aws_lambda_function" "default" {
	filename = local.lambda_zip
	function_name = substr("${var.name}--${random_id.default.hex}", 0, 64)
	handler = var.handler
	role = aws_iam_role.default.arn
	runtime = var.runtime
	source_code_hash = data.archive_file.default.output_base64sha256
	timeout = var.timeout_after_seconds

	environment {
		// * Environmental keys must not container hyphens "-" https://stackoverflow.com/a/60885479
		variables = merge([for env in var.environment: { (env["key"]) = (env["value"]) }]...)
	}
}
resource "random_id" "default" {
	byte_length = 32
}
