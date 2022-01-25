data "external" "github" {
  // Used in the custom script extension
  program = ["bash", "${path.module}/raw_uri_path.sh"]
}

// resource "azurerm_marketplace_agreement" "windows_server_2022" {
//   publisher = "microsoftwindowsserver"
//   offer     = "microsoftserveroperatingsystems-previews"
//   plan      = "windows-server-2022-azure-edition-preview"
// }

resource "azurerm_network_interface" "vm" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.name}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "${var.name}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  // depends_on          = [azurerm_marketplace_agreement.windows_server_2022]

  network_interface_ids = [azurerm_network_interface.vm.id]
  size                  = "Standard_D2_v4"
  computer_name         = "${var.name}-vm"
  admin_username        = "richeney"
  admin_password        = "Moorepay2021"
  provision_vm_agent    = true

  os_disk {
    name                 = "${var.name}-os"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  plan {
    name      = "windows-server-2022-azure-edition-preview"
    publisher = "microsoftwindowsserver"
    product   = "microsoftserveroperatingsystems-previews"
  }

  source_image_reference {
    publisher = "microsoftwindowsserver"
    offer     = "microsoftserveroperatingsystems-previews"
    sku       = "windows-server-2022-azure-edition-preview"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm" {
  for_each = toset(var.script != null ? [var.script] : [])
  name                 = "install-${var.script}-on-${var.name}"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  // The coalesce function returns the first, i.e. the master script if more than one file is in the fileUris.
  // Basename then strips the directory
  // (The ellipsis on the array converts a list of strings to a set of comma delimited arguments.)

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File edge.ps1"
    fileUris = [
      "${data.external.github.result["raw_uri_path"]}/powershell/edge.ps1",
      "${data.external.github.result["raw_uri_path"]}/powershell/msedge.admx",
      "${data.external.github.result["raw_uri_path"]}/powershell/msedge.adml"
    ]
  })
}
