variable "qemu_accelerator" {
  type    = string
  default = "kvm"
}

variable "centos_version" {
  type        = string
  default     = "7"
  description = "I know it has been EOL, but CUSTOMER still love it."
}

variable "cn_flag" {
  type    = string
  default = "false"
}

variable "allow_root_login" {
  type    = string
  default = "false"
}

variable "allow_password_login" {
  type    = string
  default = "false"
}

locals {
  ssh_private_key_file = "ssh_key"
  ssh_public_key_file  = "ssh_key.pub"
  meta_data_content    = file("${path.cwd}/http/meta-data")
  user_data_content = templatefile("${path.cwd}/http/user-data.pkrtpl.hcl", {
    ssh_public_key = file("${path.cwd}/${local.ssh_public_key_file}")
  })
}

source "qemu" "centos" {
  accelerator = var.qemu_accelerator
  cd_content = {
    "/meta-data" = local.meta_data_content
    "/user-data" = local.user_data_content
  }
  cd_label                  = "cidata"
  disk_compression          = true
  disk_image                = true
  disk_size                 = "8G"
  headless                  = true
  iso_checksum              = "284aab2b23d91318f169ff464bce4d53404a15a0618ceb34562838c59af4adea"
  iso_url                   = "https://mirror.nju.edu.cn/centos-cloud/centos/7/images/CentOS-7-x86_64-GenericCloud-2211.qcow2"
  output_directory          = "${var.cn_flag == "true" ? "output-centos-cn" : "output-centos"}"
  shutdown_command          = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username              = "builder"
  ssh_private_key_file      = local.ssh_private_key_file
  ssh_clear_authorized_keys = true
  vm_name                   = "centos-7.img"

  qemuargs = [
    ["-m", "2048M"],
    ["-smp", "2"],
    ["-serial", "mon:stdio"],
  ]
}

build {
  sources = ["source.qemu.centos"]

  provisioner "shell" {
    // run scripts with sudo, as the default cloud image user is unprivileged
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    environment_vars = [
      "CN_FLAG=${var.cn_flag}",
      "ALLOW_ROOT_LOGIN=${var.allow_root_login}",
      "ALLOW_PASSWORD_LOGIN=${var.allow_password_login}"
    ]

    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/rhel-install.sh",
      "scripts/beautify-ssh.sh",
      "scripts/rhel-cleanup.sh"
    ]
  }
}