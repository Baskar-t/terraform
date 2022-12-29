data "sops_file" "default" {
  	source_file = "${var.file_path}"
}
