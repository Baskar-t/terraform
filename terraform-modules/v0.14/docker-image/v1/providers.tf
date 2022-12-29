terraform {
	required_version = "~> 0.14.0"

	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
		random = {
			source = "hashicorp/random"
			version = "~> 3.0"
		}
		time = {
			source = "hashicorp/time"
			version = "~> 0.6.0"
		}
	}
}