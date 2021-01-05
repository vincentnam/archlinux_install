# Active EFI setting

#!/bin/bash
# 3 virtual disks : 
# boot : 300 Mo (SSD) (/dev/sdb)
# Root : 100 Go (SSD) (/dev/sdc)
# Data : 400 Go (HDD) (/dev/sda) -> home partition
# Swap : 32 Go  (HDD : because I didn't wanted to use SSD) (/dev/sdc)
# Partition creation 
cfdisk /dev/sda
# -> GPT -> whole disk as a partition
cfdisk /dev/sdb
# -> GPT -> whole disk as a partition
cfdisk /dev/sdc 
# -> GPT -> whole disk as a partition
# Add -f if partition alread has been formatted
mkfs.xfs -L "Data" /dev/sda1
mkfs.fat -F 32 -n "Boot" /dev/sdb1
mkfs.btrfs -L "Root" /dev/sdc1
mkswap /dev/sdd
ROOT_PART=/dev/sdc
HOME_PART=/dev/sda
BOOT_PART=/dev/sdb
SWAP_PART=/dev/sdd

mount -o rw,suid,dev,exec,auto,nouser,async,relatime,discard,ssd,nodev /dev/nvme0n1p7 /mnt/
btrfs subvolume create /mnt/@

btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshot
umount /mnt


mount -o rw,exec,auto,async,nouser,relatime,discard,ssd,nodev,space_cache=v2,compress=lzo,subvol=@ ${ROOT_PART} /mnt/
mkdir -p /mnt/{boot/efi,home,var/log,var/cache/pacman/pkg,btrfs}
mount -o rw,exec,auto,async,nouser,relatime,discard,ssd,nodev,space_cache=v2,compress=lzo,subvol=@log ${ROOT_PART} /mnt/var/log/
mount -o rw,exec,auto,async,nouser,relatime,discard,ssd,nodev,space_cache=v2,compress=lzo,subvol=@pkg ${ROOT_PART} /mnt/var/cache/pacman/pkg/
mount -o rw,exec,auto,async,nouser,relatime,discard,ssd,nodev,space_cache=v2,compress=lzo,subvolid=5 ${ROOT_PART} /mnt/btrfs
mount ${HOME_PART} /mnt/home/
mount ${BOOT_PART} /mnt/boot/efi/

swapon ${SWAP_PART}

pacman -S pacman archlinux-keyring

pacstrap /mnt base base-devel archlinux-keyring btrfs-progs xfsprogs dosfstools grub efibootmgr vim
genfstab -U -p /mnt >> /mnt/etc/fstab

sed -i '/fr_FR.UTF-8/s/^#//g' /etc/locale.gen 
export LANG=fr_FR.UTF-8

echo LANG=fr_FR.UTF-8 > /etc/locale.conf 
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime 
locale-gen \n

pacman --noconfirm -S mkinitcpio zsh vim efibootmgr networkmanager archlinux-keyring linux linux-firmware pacman 

	sed -i 's/SigLevel    = Required DatabaseOptional/SigLevel    = Never/g' /etc/pacman.conf\n
	sed -i '/fr_FR.UTF-8/s/^#//g' /etc/locale.gen \n
	export LANG=fr_FR.UTF-8\n
	wait \n
	echo LANG=fr_FR.UTF-8 > /etc/locale.conf \n
	ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime \n
	wait\n
	locale-gen \n
	wait\n
	pacman --noconfirm -S mkinitcpio zsh vim efibootmgr networkmanager archlinux-keyring linux linux-firmware pacman archlinux-keyring \n
	wait \n
	hwclock --systohc --utc \n
	echo 'vincentnam' > /etc/hostname \n
	sed -i 's/mymachine/Virtualmachine/g' /etc/nsswitch.conf \n
	sed -i 's/myhostname/vincentnam/g' /etc/nsswitch.conf \n
	systemctl enable NetworkManager \n
	sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block filesystems keyboard )/g' /etc/mkinitcpio.conf \n
	passwd \n
	groupadd vincentnam \n
	groupadd sudo \n
	wait \n
	useradd -m -g vincentnam -G users,wheel,storage,power,network,sudo -s /bin/zsh -c \"Vincent-Nam DANG\" vincentnam \n
	wait \n
	passwd vincentnam \n
	systemctl enable NetworkManager.service \n
	grub-install --target=x86_64-efi --efi-directory=/boot/efi/ --recheck ${INSTALL_DISK} \n
	wait\n
	grub-mkconfig -o /boot/grub/grub.cfg	\n

  pacman --noconfirm -S nvidia snapper plasma-meta xorg xorg-server xorg-apps xorg-xinit xterm yakuake 
  
  echo \"KEYMAP=fr\" > /etc/vconsole.conf \n
	export LANG=fr_FR.UTF-8
	sed -i '/fr_FR.UTF-8/s/^#//g' /etc/locale.gen \n
	wait \n
	printf \"LANG=${LANGE}\" > /etc/locale.conf \n
	locale-gen \n
	wait\n
	pacman --noconfirm -S nvidia snapper plasma-meta xorg xorg-server xorg-apps xorg-xinit xterm yakuake \n
	sddm --example-config > /etc/sddm.conf \n
	sed -i 's/User=/User=vincentnam/g' /etc/sddm.conf \n
	sed -i 's/Session=/Session=\/usr\/share\/xsessions\/plasma.desktop/g' /etc/sddm.conf \n
	systemctl enable sddm\n
	printf \"setxkbmap fr\" >> /usr/share/sddm/scripts/Xsetup \n
	pacman --noconfirm -S ttf-dejavu" > /mnt/config.sh
