# archlinux_install
##### Warning : This is not an installer, just a script that I used for my system : you might have to adapt it to your system and willing to make it usable !

### Information
Repo for install script of dual boot Windows 10 / Arch Linux.
The installation is : 
  - UEFI system
  - Dual boot Arch Linux / Windows 10
  - Grub 2 for bootloader
  - SDDM / KDE graphic environnement
  - BTRFS used for snapshots
  - Nvidia GeForce GTX 1070 Mobile installed (graphic driver)
  - Double drive : Hard Disk Drive 1TO + 256 Go SSD  
  
  
The goals was to :
  - Have snapshots for system management
  - Install Graphic Card drivers and tools for machine learning training on graphic card (Tensorflow)

Boot loader need to be on a FAT32 partition.
Configuration of BTRFS is done to not snap pkg cache and home (~).
Swap is on.
Data folder at root is done for HardDrive where data are (dataset, files, works)
### Pre-install 

To install this config, you have to boot on a bootable USB key with live CD of Arch Linux.
Get the script (mount a drive / key or get through this repo (git clone)) and launch the script. 
Reboot and boot on the Arch Linux partition. You can now configure your environnement.
You can find everywhere information about partition setup.

You have to prepare partition before. My setup was : 
  - SDA : HDD 1 TO
    - SDA1 : Data partition for Windows
    - SDA2 : Data partition for Linux
  - nvme0 : SDD 256 GO
    - nvme0n1p1 -> nvme0n1p4 : Boot partition for windows
    - nvme0n1p5 : boot partition : FAT32 : ~ 530Mo is too much but I had enough place to get more than needed. It should need approximatively ~ 250 Mo (maybe less)
    - nvme0n1p6 : Swap Partition for linux : Swap type 32Go - Less or no swap is possible but I may need to load high ammount of data in memory so I need swap
    - nvme0n1p7 : Root partition : Installation part in BTRFS for snapshot 181Go
    - nvme0n1p8 : Home partition : XFS (Any FS is possible because we want to snap home - XFS is suppose to be high performance FS) 38.8 Go 
    
lsblk -f return : 
  
  |NAME|FSTYPE|FSVER|LABEL|UUID|FSAVAIL|FSUS%|MOUNTPOINT|    
  |------------|------------|------------|------------|------------|------------|------------|------------    
  | sda          | | | | | | ||                                                                 
  |   ├─sda1      | ntfs | |         DATA|          4844B0F144B0E33C|||                                    
  |   └─sda2      |btrfs |  | |                  ef9b28af-c684-45af-8003-04d6d278ff98  |160.3G|    63%| /data|
  | nvme0n1||||||                                                                                   
  |  ├─nvme0n1p1 |ntfs  |       |Récupération| 068CD53A8CD52549|                              |     | |
  |  ├─nvme0n1p2 |vfat  | FAT32 |         |    84D7-0371        |                             |     | |
  |  ├─nvme0n1p3 |      |       |         |                      |                            |     | |
  |  ├─nvme0n1p4 |ntfs  |       |         |   423AF6983AF687E5   |                            |    | |
  |  ├─nvme0n1p5 |vfat  | FAT32 |ArchBoot |    F5EA-0CA3         |                    510.7M |    0%| /boot/efi|
  |  ├─nvme0n1p6 |swap  | 1     |         |    db8b7f1c-c0b5-4ad1-ba33-15d5cc24e1f8  |       |      | [SWAP]|
  |  ├─nvme0n1p7 |btrfs|        |ArchRoot |    49824e86-add9-49af-b93a-1bc35c300382  |145.9G |   19%| /btrfs|
  |  └─nvme0n1p8 |xfs |         |ArchHome|     64e3d34f-1812-48b7-af1b-5f7b8ebe2dd2  | 26.4G|    32%| /home|


### Configuration

    pacstrap /mnt base base-devel archlinux-keyring btrfs-progs xfsprogs dosfstools grub efibootmgr

This line is base package installation. Change package here if you want to install different file system. 


Post script installation for BTRFS snapshot configuration (OpenSUSE way): 
https://www.youtube.com/watch?v=TKdZiCTh3EM



### Machine Learning 

The best solution is to use Docker (see docker installation on Arch Linux wikipedia for GPU usage for containers). Indeed, packages on Arch Linux, packages are often updated. You'll have quickly a difference between the Nvidia drivers and Tensorflow compilation driver version. 
You can download a Tensorflow-GPU driver and install driver for Docker to use GPU. It won't break at the first update and you'll be able to manage your versions easily.

### TODO :
  - Encrypt disk and set up a passwd

### Credits - Generic

This script is maybe not in his final version and you may need to configure this script to fit to your configuration. 
If you want don't have graphic card, remove Nvidia Package 

Don't hesitate to make an issue or send me a mail at dang.vincentnam@gmail.com if you have questions / improvement for this project.
