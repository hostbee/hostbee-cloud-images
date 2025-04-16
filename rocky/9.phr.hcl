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

source "qemu" "rocky" {
  accelerator               = var.qemu_accelerator
  cd_files                  = ["./http/*"]
  cd_label                  = "cidata"
  disk_compression          = true
  disk_image                = true
  disk_size                 = "10G"
  headless                  = true
  iso_checksum              = "file:https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2.CHECKSUM"
  iso_url                   = "https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  output_directory          = "${var.cn_flag == "true" ? "output-rocky-9-cn" : "output-rocky-9"}"
  shutdown_command          = "sudo -S shutdown -P now"
  ssh_username              = "builder"
  ssh_private_key_file      = local.ssh_private_key_file
  ssh_clear_authorized_keys = true
  vm_name                   = "${var.cn_flag == "true" ? "rocky-9-cn.img" : "rocky-9.img"}"
  cpu_model                 = "host"

  qemuargs = [
    ["-m", "4096M"],
    ["-smp", "4"],
    ["-serial", "mon:stdio"],
  ]
}

build {
  sources = ["source.qemu.rocky"]

  provisioner "shell" {
    // run scripts with sudo, as the default cloud image user is unprivileged
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    
    environment_vars = [
    "CN_FLAG=${var.cn_flag}"
    ]

    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/rocky-9-install.sh",
      "scripts/beautify-ssh.sh",
      "scripts/rhel-cleanup.sh"
    ]
  }
}