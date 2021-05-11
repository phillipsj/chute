data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "package_upgrade: ${var.update_server}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "packages: ['docker']"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['systemctl enable --now docker', '${var.docker_cmd}']"
  }
}