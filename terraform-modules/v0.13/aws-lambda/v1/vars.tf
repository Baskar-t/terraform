variable "environment" {
	default = [{ key = "TERRAFORM_PLACEHOLDER", value = "1" }]
	type = list(object({
		key = string
		value = string
	}))
}
variable "excluded_files" {
	default = []
	type = list(string)
}
variable "handler" {
	type = string
}
variable "name" {
	type = string
}
variable "runtime" {
	type = string
}
variable "source_directory" {
	type = string
}
variable "timeout_after_seconds" {
	default = 3
	type = number

	validation {
		condition = 0 <= var.timeout_after_seconds && var.timeout_after_seconds <= 900
		error_message = "Variable 'timeout_after_seconds' must be between 0 - 900 seconds."
	}
}
