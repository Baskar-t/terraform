terraform {
	required_version = "~> 0.13.0"

	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
		random = {
			source = "hashicorp/random"
			version = "~> 2.0, >= 2.3.0"
		}
		time = {
			source = "hashicorp/time"
			version = "~> 0.5.0"
		}
	}
}
