terraform {
	experiments = [variable_validation]
	required_version = "~> 0.12.0"

	required_providers {
		heroku = "~> 2.5"
	}
}
