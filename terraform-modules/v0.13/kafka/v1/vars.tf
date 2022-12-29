variable "name" {
	description = "Name of the application"
	type = string

	validation {
		condition = length(var.name) <= 30
		error_message = "Varaible 'name' has a max of 30 characters."
	}
}
variable "plan" {
	default = "cloudkarafka:mouse-1"
	description = "Heroku plan for the specified addon"
	type = string
}
