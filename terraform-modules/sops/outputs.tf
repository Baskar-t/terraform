output "json" {
	value = jsondecode(data.sops_file.default.raw)
}
