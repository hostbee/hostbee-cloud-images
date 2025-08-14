variable "qemu_accelerator" {
  type    = string
  default = "kvm"
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

source "qemu" "almalinux" {
  accelerator = var.qemu_accelerator
  cd_content = {
    "/meta-data" = local.meta_data_content
    "/user-data" = local.user_data_content
  }
  cd_label                  = "cidata"
  disk_compression          = true
  disk_image                = true
  disk_size                 = "10G"
  headless                  = true
  iso_checksum              = "file:https://mirror.nju.edu.cn/almalinux/9/cloud/x86_64/images/CHECKSUM"
  iso_url                   = "https://mirror.nju.edu.cn/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
  output_directory          = "${var.cn_flag == "true" ? "output-almalinux-9-cn" : "output-almalinux-9"}"
  shutdown_command          = "sudo -S /root/cleanup.sh"
  shutdown_timeout          = "15s"
  ssh_username              = "builder"
  ssh_private_key_file      = local.ssh_private_key_file
  ssh_clear_authorized_keys = true
  vm_name                   = "almalinux-9.img"
  cpu_model                 = "host"

  qemuargs = [
    ["-m", "4096M"],
    ["-smp", "4"],
    ["-serial", "mon:stdio"],
  ]
}

build {
  sources = ["source.qemu.almalinux"]

  provisioner "shell" {
    // run scripts with sudo, as the default cloud image user is unprivileged
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    environment_vars = [
      "CN_FLAG=${var.cn_flag}",
      "ALLOW_ROOT_LOGIN=${var.allow_root_login}",
      "ALLOW_PASSWORD_LOGIN=${var.allow_password_login}"
    ]

    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/almalinux-9-install.sh",
      "scripts/beautify-ssh.sh",
      "scripts/rhel-cleanup.sh",
      "scripts/user-cleanup.sh"
    ]
  }
}