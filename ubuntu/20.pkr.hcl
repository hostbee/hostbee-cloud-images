variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
  description = "Qemu accelerator to use. On Linux use kvm and macOS use hvf."
}

variable "ubuntu_version" {
  type        = string
  default     = "focal"
}

variable "cn_flag" {
  type        = string
  default     = "false"
}

locals {
  ssh_private_key_file = "ssh_key"
  ssh_public_key_file  = "ssh_key.pub"
}

source "qemu" "ubuntu" {
  accelerator      = var.qemu_accelerator
  cd_files         = ["./http/*"]
  cd_label         = "cidata"
  disk_compression = true
  disk_image       = true
  disk_size        = "10G"
  headless         = true
  iso_checksum     = "file:https://cloud-images.ubuntu.com/${var.ubuntu_version}/current/SHA256SUMS"
  iso_url          = "https://cloud-images.ubuntu.com/${var.ubuntu_version}/current/${var.ubuntu_version}-server-cloudimg-amd64.img"
  output_directory = "${var.cn_flag == "true"? "output-ubuntu-20-cn" : "output-ubuntu-20"}"
  shutdown_command = "sudo -S shutdown -P now"
  ssh_username           = "builder"
  ssh_private_key_file   = local.ssh_private_key_file
  ssh_clear_authorized_keys = true
  vm_name          = "${var.cn_flag == "true"? "ubuntu-20-cn.img" : "ubuntu-20.img"}"

  qemuargs = [
    ["-m", "2048M"],
    ["-smp", "2"],
    ["-serial", "mon:stdio"],
  ]
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    // run scripts with sudo, as the default cloud image user is unprivileged
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    environment_vars = [
      "CN_FLAG=${var.cn_flag}"
    ]
    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/ubu-20-install.sh",
      "scripts/beautify-ssh.sh",
      "scripts/ubu-cleanup.sh"
    ]
  }
}