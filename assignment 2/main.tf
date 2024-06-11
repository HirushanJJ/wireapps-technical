provider "azurerm" {
  features {}
  subscription_id = "b5e4b9c5-1d3f-4f80-a8a7-70a8527329fd"
}

data "azurerm_resource_group" "Wireapps" {
  name     = "Wireapps"
  location = "Japan East"
}

data "azurerm_virtual_network" "WireappsVMImage_vnet" {
  name                = "Wireapps0-vmimage561_z1"
  resource_group_name = azurerm_resource_group.Wireapps
}

resource "azurerm_subnet" "WireappsVMImage_subnet" {
  name                 = "WireappsVMImage-subnet"
  resource_group_name  = azurerm_resource_group.Wireapps.name
  virtual_network_name = azurerm_virtual_network.WireappsVMImage_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "WireappsVMImage_publicip" {
  name                = "WireappsVMImage-publicip"
  location            = azurerm_resource_group.Wireapps.location
  resource_group_name = azurerm_resource_group.Wireapps.name
  allocation_method  = "Dynamic"
}

resource "azurerm_network_interface" "WireappsVMImage_nic" {
  name                = "WireappsVMImage-nic"
  location            = azurerm_resource_group.Wireapps.location
  resource_group_name = azurerm_resource_group.Wireapps.name

  ip_configuration {
    name                          = "WireappsVMImage-ipconfig"
    subnet_id                     = azurerm_subnet.WireappsVMImage_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.WireappsVMImage_publicip.id
  }
}

data "template_file" "customdata" {
  template = file("${path.module}/customdata.tpl")

  vars = {
    vm_public_ip = azurerm_public_ip.WireappsVMImage_publicip
    username = azurerm_linux_virtual_machine.WireappsVMImage.admin_username
  }
}
##################################################################################################################
resource "azurerm_linux_virtual_machine" "WireappsVMImage" {
  name                = "WireappsVMImage"
  location            = azurerm_resource_group.Wireapps.location
  resource_group_name = azurerm_resource_group.Wireapps.name
  network_interface_ids = [
    azurerm_network_interface.WireappsVMImage_nic.id
  ]

  admin_username = "azureuser"
  admin_password = "Wireapps@123"  # Replace with your desired password

  size                 = "Standard_DS1_v2"
  computer_name_prefix = "Wireappsvmimage"

  os_disk {
    name              = "wireapps-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


