terraform {
	experiments = [variable_validation]
	required_version = "~> 0.12.0"

	required_providers {
		aws = "~> 2.58"
		random = "~> 2.3"
		time = "~> 0.5"
	}
}
