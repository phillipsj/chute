data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "package_upgrade: ${var.update_server}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['curl -sfL https://get.rke2.io | sh -']"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['systemctl enable rke2-server.service', 'systemctl start rke2-server.service']"
  }
}