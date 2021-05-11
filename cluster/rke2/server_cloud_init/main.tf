data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "package_upgrade: ${var.update_server}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['id -u', 'curl -sfL https://get.rke2.io | sh', 'systemctl enable rke2-server.service', 'systemctl start rke2-server.service']"
    merge_type   = "list()+dict()+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['while [ ! -f /var/lib/rancher/rke2/server/node-token ]; do sleep 2; done;']"
    merge_type   = "list(append)+dict()+str()"
  }

  part {
    content_type = "text/cloud-config"
    content      = "runcmd: ['curl -X PUT -T /var/lib/rancher/rke2/server/node-token -H \"x-ms-date: $(date -u)\" -H \"x-ms-blob-type: BlockBlob\" \"https://${var.storage_account_name}.blob.core.windows.net/${var.container_name}/node-token?${var.sas_token}']"
    merge_type   = "list(append)+dict()+str()"
  }



}