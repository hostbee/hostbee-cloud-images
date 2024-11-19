variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
  description = "Qemu accelerator to use. On Linux use kvm and macOS use hvf."
}

variable "debian_version" {
  type        = string
  default     = "bookworm"
}

source "qemu" "debian" {
  accelerator      = var.qemu_accelerator
  cd_files         = ["./http/*"]
  cd_label         = "cidata"
  disk_compression = true
  disk_image       = true
  disk_size        = "10G"
  headless         = true
  iso_checksum     = "c939658113d6cd16398843078a942557048111db99442156498b2c5185461366ad7e52ac415b3f00b348cd81cf07333e6793faa0752fd3fbc725e39232f8e93a"
  iso_url          = "https://cdimage.debian.org/images/cloud/bookworm/20241110-1927/debian-12-genericcloud-amd64-20241110-1927.qcow2"
  output_directory = "output-bookworm-1"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password     = "Password"
  ssh_username     = "debian"
  vm_name          = "debian-bookworm.img"

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
    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/install.sh",
      "scripts/cleanup.sh"
    ]
  }
}