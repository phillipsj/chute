output "cloud-init-rendered" {
  value = data.template_cloudinit_config.config.rendered
}