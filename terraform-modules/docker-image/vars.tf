variable "environment" {
	default = []
	description = "A list of environmental varaibles for the application"
	type = list(
		object({
			key = string
			value = string
		})
	)
}
variable "image" {
	description = "The application's docker image"
	type = string
}
variable "max" {
	default = 10
	description = "Maximum auto-scale limit."
	type = number
}
variable "min" {
	default = 1
	description = "Minimum auto-scale limit."
	type = number
}
variable "name" {
	description = "Name of the application"
	type = string

	validation {
		condition = 5 <= length(var.name) && length(var.name) <= 40
		error_message = "Variable 'name' must between 5 - 40 characters in length."
	}
}
variable "registry_password" {
	default = ""
	description = "Password for access to private docker image registry"
	type = string
}
variable "registry_username" {
	default = ""
	description = "Username for access to private docker image registry"
	type = string
}
variable "port" {
	default = 8080
	description = "The exposed container port for the Docker image"
	type = number
}
variable "type" {
	default = "worker"
	description = "The type of instance that will be running"
	type = string

	validation {
		condition = var.type == "website" || var.type == "worker"
		error_message = "Variable 'type' can only be 'website' or 'worker'."
	}
}
