variable "subscription_id" {
  description = "Subscription ID to use."
  type        = string
}

variable "vm_size" {
  description = "Size of the VM for Packer to use. The default size is `Standard_A2_v2`."
  type        = string
  default     = "Standard_A2_v2"
}

variable "location" {
  description = "The location for packer to create image. The default location is `East US`."
  type        = string
  default     = "East US"
}

variable "replication_regions" {
  description = "The list of regions to replicated the shared region. The default region is `East US`."
  type        = list(string)
  default     = ["East US"]
}

variable "resource_group" {
  description = "The resource group for Packer and the Shared Image. The default is `RancherImages`."
  type        = string
}

variable "version" {
  description = "The version number for the shared image. The default is `0.1.0`."
  type        = string
  default     = "0.1.0"
}

source "azure-arm" "docker" {
  use_azure_cli_auth = true

  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.resource_group
    gallery_name        = "ranchergallery"
    image_name          = "Windows2019Docker"
    image_version       = var.version
    replication_regions = var.replication_regions
  }

  managed_image_name                = "Windows2019Docker"
  managed_image_resource_group_name = var.resource_group

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"

  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "3m"
  winrm_username = "packer"

  location = var.location
  vm_size  = var.vm_size
}

build {
  sources = ["sources.azure-arm.docker"]

  provisioner "powershell" {
    pause_before = "5m"
    inline = [
      "$ErrorActionPreference = 'Stop'",
      "Write-Host 'Starting Docker installation...'",
      "Write-Host 'Installing NuGet Provider...'",
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force",
      "Write-Host 'Installing Docker Provider...'",
      "Install-Module -Name DockerMsftProvider -AllowClobber -Confirm:$false -Force",
      "Write-Host 'Installing Package...'",
      "Install-Package -Name docker -ProviderName DockerMsftProvider -Confirm:$false -Force",
      "Write-Host 'Completed Docker installation...'"
    ]
  }

  provisioner "windows-restart" {
    pause_before = "1m"
  }

  provisioner "powershell" {
    pause_before = "3m"
    inline = [
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }",
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
    ]
  }
}
