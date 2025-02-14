variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
  description = "Qemu accelerator to use. On Linux use kvm and macOS use hvf."
}

variable "debian_version" {
  type        = string
  default     = "bookworm"
}

variable "cn_flag" {
  type        = string
  default     = "false"
}

source "qemu" "debian" {
  accelerator      = var.qemu_accelerator
  cd_files         = ["./http/*"]
  cd_label         = "cidata"
  disk_compression = true
  disk_image       = true
  disk_size        = "10G"
  headless         = true
  iso_checksum_url = "file:https://cdimage.debian.org/images/cloud/bullseye/latest/SHA512SUMS"
  iso_url          = "https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
  output_directory = "${var.cn_flag == "true" ? "output-debian-11-cn" : "output-debian-11"}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password     = "Password"
  ssh_username     = "debian"
  vm_name          = "${var.cn_flag == "true" ? "debian-11-cn.img" : "debian-11.img"}"

  qemuargs = [
    ["-m", "2048M"],
    ["-smp", "2"],
    ["-serial", "mon:stdio"],
  ]
}

build {
  sources = ["source.qemu.debian"]

  provisioner "shell" {
    // run scripts with sudo, as the default cloud image user is unprivileged
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    environment_vars = [
    "CN_FLAG=${var.cn_flag}"
    ]
    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/deb-11-install.sh",
      "scripts/beautify-ssh.sh",
      "scripts/deb-cleanup.sh"
    ]
  }
}