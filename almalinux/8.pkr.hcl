variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
}

variable "cn_flag" {
  type        = string
  default     = "false"
}

locals {
  ssh_private_key_file = "ssh_key"
  ssh_public_key_file  = "ssh_key.pub"
}

source "qemu" "almalinux" {
  accelerator               = var.qemu_accelerator
  cd_files                  = ["./http/*"]
  cd_label                  = "cidata"
  disk_compression          = true
  disk_image                = true
  disk_size                 = "10G"
  headless                  = true
  iso_checksum              = "file:https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/CHECKSUM"
  iso_url                   = "https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/almalinux-8-GenericCloud-latest.x86_64.qcow2"
  output_directory          = "${var.cn_flag == "true" ? "output-almalinux-cn" : "output-almalinux"}"
  shutdown_command          = "sudo -S shutdown -P now"
  ssh_username              = "builder"
  ssh_private_key_file      = local.ssh_private_key_file
  ssh_clear_authorized_keys = true
  vm_name                   = "${var.cn_flag == "true" ? "almalinux-8-cn.img" : "almalinux-8.img"}"
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
    "CN_FLAG=${var.cn_flag}"
    ]

    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/almalinux-8-install.sh",
      "scripts/beautify-ssh.sh",
      "scripts/rhel-cleanup.sh"
    ]
  }
}