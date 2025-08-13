# hostbee cloud images
This repository contains the packer templates for the hostbee cloud images.

## Usage
To build the images, you need to have packer installed on your system. Once you have it installed, you can run the following command from the root directory of this repository:

### Init

```
packer init .
```

### Build

|   Image   |             Command              |
|  -------  |            ---------             |
| Debian 12 | `packer build debian/12.pkr.hcl` |
| Ubuntu 24 | `packer build ubuntu/24.pkr.hcl` |

Additionally, you can build the images for mainland China by setting the `cn_flag` to `true`. For example:

```
packer build -var cn_flag=true debian/12.pkr.hcl
```

This will build the Debian 12 image with the mainland China mirrors.

Full OS list:
- almalinux/8.pkr.hcl
- almalinux/9.pkr.hcl
- debian/11.pkr.hcl
- debian/12.pkr.hcl
- rocky/8.pkr.hcl
- rocky/9.pkr.hcl
- ubuntu/20.pkr.hcl
- ubuntu/22.pkr.hcl
- ubuntu/24.pkr.hcl
