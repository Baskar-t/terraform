data "sops_file" "default" {
  	source_file = "${path.cwd}/${var.file_path}"
}
