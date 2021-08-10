resource "azurerm_resource_group" "relay" {
  name     = "moorepay-relay"
  location = "West Europe"
}

resource "azurerm_resource_group" "greenford" {
  name     = "moorepay-greenford"
  location = "West Europe"
}

resource "azurerm_resource_group" "azure" {
  name     = "moorepay-azure"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "moorepay" {
  name                = "moorepay-relay"
  location            = azurerm_resource_group.relay.location
  resource_group_name = azurerm_resource_group.relay.name
  sku_name            = "Standard"
}

//==========================================================================

resource "azurerm_virtual_network" "a" {
  name                = "vnet-a"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.greenford.location
  resource_group_name = azurerm_resource_group.greenford.name
}

resource "azurerm_subnet" "a" {
  name                 = "sn-default"
  resource_group_name  = azurerm_resource_group.greenford.name
  virtual_network_name = azurerm_virtual_network.a.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "a_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.greenford.name
  virtual_network_name = azurerm_virtual_network.a.name
  address_prefixes     = ["10.0.255.224/27"]
}

resource "azurerm_virtual_network" "b" {
  name                = "vnet-b"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name
}

resource "azurerm_subnet" "b" {
  name                 = "sn-default"
  resource_group_name  = azurerm_resource_group.azure.name
  virtual_network_name = azurerm_virtual_network.b.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "b_asp" {
  name                 = "asp"
  resource_group_name  = azurerm_resource_group.azure.name
  virtual_network_name = azurerm_virtual_network.b.name
  address_prefixes     = ["10.1.1.0/24"]

  service_endpoints = ["Microsoft.Web"]
}

resource "azurerm_subnet" "b_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.azure.name
  virtual_network_name = azurerm_virtual_network.b.name
  address_prefixes     = ["10.1.255.224/27"]
}

//==========================================================================

module "greenford_bastion" {
  source              = "./modules/bastion"
  name                = "greenford"
  resource_group_name = azurerm_resource_group.greenford.name
  location            = azurerm_resource_group.greenford.location
  subnet_id           = azurerm_subnet.a_bastion.id
}

module "azure_bastion" {
  source              = "./modules/bastion"
  name                = "azure"
  resource_group_name = azurerm_resource_group.azure.name
  location            = azurerm_resource_group.azure.location
  subnet_id           = azurerm_subnet.b_bastion.id
}

//==========================================================================

module "iis" {
  source              = "./modules/windows_server"
  name                = "iis"
  resource_group_name = azurerm_resource_group.greenford.name
  location            = azurerm_resource_group.greenford.location

  subnet_id = azurerm_subnet.a_bastion.id
  script    = "iis"
}
