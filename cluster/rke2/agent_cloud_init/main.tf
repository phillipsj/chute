data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "package_upgrade: ${var.update_server}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['id -u', 'curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=\"agent\" sh', 'systemctl enable rke2-agent.service']"
    merge_type   = "list(append)+dict()+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['mkdir -p /etc/rancher/rke2/', 'touch /etc/rancher/rke2/config.yaml']"
    merge_type   = "list(append)+dict()+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['curl -X GET -H \"x-ms-date: $(date -u)\" \"https://${var.storage_account_name}.blob.core.windows.net/${var.container_name}/node-token?${var.sas_token}'']"
    merge_type   = "list(append)+dict()+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['echo \"server: https://${var.rke_server}:9345\" >> /etc/rancher/rke2/config.yaml']"
    merge_type   = "list(append)+dict()+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['echo \"token: ${var.token}\" >> /etc/rancher/rke2/config.yaml']"
    merge_type   = "list(append)+dict()+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['systemctl start rke2-agent.service']"
    merge_type   = "list(append)+dict()+str()"
  }
}