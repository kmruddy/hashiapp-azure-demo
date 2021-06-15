provider "random" {}

resource "random_shuffle" "happ_name" {
  input        = ["Vagrant", "Packer", "Terraform", "Vault", "Nomad", "Consul", "Waypoint", "Boundary"]
  result_count = 1
}

data "terraform_remote_state" "haarg" {
  backend = "remote"

  config = {
    organization = "TPMM-Org"
    workspaces = {
      name = "hashiapp-azure-resourcegroup"
    }
  }
}

data "terraform_remote_state" "haan" {
  backend = "remote"

  config = {
    organization = "TPMM-Org"
    workspaces = {
      name = "hashiapp-azure-network"
    }
  }
}

data "terraform_remote_state" "haavm" {
  backend = "remote"

  config = {
    organization = "TPMM-Org"
    workspaces = {
      name = "hashiapp-azure-vm"
    }
  }
}

resource "null_resource" "configure-happ" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/${data.terraform_remote_state.haavm.outputs.credentials.username}/"

    connection {
      type     = "ssh"
      user     = data.terraform_remote_state.haavm.outputs.credentials.username
      password = data.terraform_remote_state.haavm.outputs.credentials.password
      host     = data.terraform_remote_state.haan.outputs.happ_fqdn
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start apache2",
      "sudo chown -R ${data.terraform_remote_state.haavm.outputs.credentials.username}:${data.terraform_remote_state.haavm.outputs.credentials.username} /var/www/html",
      "chmod +x *.sh",
      "URL=${var.hashi_products[random_shuffle.happ_name.result]} HAPP=${random_shuffle.happ_name.result} PREFIX=${data.terraform_remote_state.haarg.outputs.rg_name} FQDN=${data.terraform_remote_state.haan.outputs.happ_fqdn} VMNAME=${data.terraform_remote_state.haavm.outputs.vmname} ./deploy_app.sh",
    ]

    connection {
      type     = "ssh"
      user     = data.terraform_remote_state.haavm.outputs.credentials.username
      password = data.terraform_remote_state.haavm.outputs.credentials.password
      host     = data.terraform_remote_state.haan.outputs.happ_fqdn
    }
  }
}

output "happ_fqdn" {
  value = data.terraform_remote_state.haan.outputs.happ_fqdn
}
