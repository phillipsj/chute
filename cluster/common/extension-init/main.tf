resource "azurerm_virtual_machine_extension" "init" {
  name                 = "init"
  virtual_machine_id   = var.virtual_machine_id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/phillipsj/chute/main/scripts/init.ps1"],
        "commandToExecute": "powershell.exe -ExecutionPolicy Bypass init.ps1 -Command ${var.docker_cmd}",
    }
SETTINGS

  tags = var.tags
}