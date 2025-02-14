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
  iso_checksum     = "a5fc7e7c055de3ba47a2bda105fad21c9b645163583e9e45311adab5bb552551e5ed131d5ccab6c3b1257a60689fd9140b0a40f93cd64c6dcc31210c0bb9386e"
  iso_url          = "https://cdimage.debian.org/images/cloud/bookworm/20241110-1927/debian-12-generic-amd64-20241110-1927.qcow2"
  output_directory = "${var.cn_flag == "true" ? "output-debian-cn" : "output-debian"}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password     = "Password"
  ssh_username     = "debian"
  vm_name          = "${var.cn_flag == "true" ? "debian-bookworm-cn.img" : "debian-bookworm.img"}"

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
      "scripts/deb-12-install.sh",
      "scripts/beautify-ssh.sh",
      "scripts/deb-cleanup.sh"
    ]
  }
}