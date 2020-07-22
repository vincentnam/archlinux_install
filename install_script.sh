#!/bin/bash 
INSTALL_DISK=/dev/nvmen0
BOOT_PART=/dev/nvme0n1p5
ROOT_PART=/dev/nvme0n1p7
HOME_PART=/dev/nvme0n1p8
SWAP_PART=/dev/nvme0n1p6
DATA_PART=/dev/sda2
LANGAGE=fr_FR.UTF-8
umount /data
set +x



mkfs.xfs -f -L "ArchHome" ${HOME_PART}
mkfs.btrfs -f -L "ArchRoot" ${ROOT_PART}
mkfs.fat -F 32 -n "ArchBoot" ${BOOT_PART}
mkswap -L "SWAP"





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

wait
mkdir /mnt/data/

mount ${DATA_PART} /mnt/data

sed -i 's/SigLevel    = Required DatabaseOptional/SigLevel    = Never/g' /etc/pacman.conf
wait
pacman -Sy --noconfirm pacman archlinux-keyring
wait

pacstrap /mnt base base-devel archlinux-keyring btrfs-progs xfsprogs dosfstools grub efibootmgr



genfstab -U -p /mnt >> /mnt/etc/fstab
wait
printf "

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
	sed -i 's/mymachine/Asus-Rog_GL504GS/g' /etc/nsswitch.conf \n
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
	sed -i 's/SigLevel    = Never/SigLevel    = Required DatabaseOptional/g' /etc/pacman.conf \n
	"  > /mnt/install.sh
wait
arch-chroot /mnt sh -x /install.sh
#arch-chroot /mnt/btrfs-current tac /boot/grub/grub.cfg | sed -i '1,20d' | tac 


echo "
### END /etc/grub.d/20_linux_xen ###

### BEGIN /etc/grub.d/30_os-prober ###
menuentry 'Windows Boot Manager (on /dev/nvme0n1p2)' --class windows --class os \$menuentry_id_option 'osprober-efi-84D7-0371' {
	insmod part_gpt
	insmod fat
	if [ x\$feature_platform_search_hint = xy ]; then
	  search --no-floppy --fs-uuid --set=root  84D7-0371
	else
	  search --no-floppy --fs-uuid --set=root 84D7-0371
	fi
	chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
### END /etc/grub.d/30_os-prober ###

### BEGIN /etc/grub.d/40_custom ###
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.

menuentry \"System shutdown\" {
	echo \"System shutting down...\"
	halt
}
menuentry \"System restart\" {
	echo \"System rebooting...\"
	reboot
}
### END /etc/grub.d/40_custom ###

### BEGIN /etc/grub.d/41_custom ###
if [ -f  \${config_directory}/custom.cfg ]; then
  source \${config_directory}/custom.cfg
elif [ -z \"\${config_directory}\" -a -f  \$prefix/custom.cfg ]; then
  source \$prefix/custom.cfg;
fi
### END /etc/grub.d/41_custom ###" >> /mnt/boot/grub/grub.cfg

#sed -i 's/#[multilib]
##Include = /etc/pacman.d/mirrorlist/#[multilib]
#Include = /etc/pacman.d/mirrorlist/g' /mnt/btrfs-current/etc/pacman.conf 
	


wait


rm /mnt/install.sh 
# Configuration part of the environnement 

printf "echo \"KEYMAP=fr\" > /etc/vconsole.conf \n
	export LANG=fr_FR.UTF-8
	sed -i '/fr_FR.UTF-8/s/^#//g' /etc/locale.gen \n
	wait \n
	printf \"LANG=${LANGE}\" > /etc/locale.conf \n
	locale-gen \n
	wait\n
	pacman --noconfirm -S nvidia snapper plasma-meta xorg xorg-server xorg-apps xorg-xinit xterm yakuake \n
	sddm --example-config > /etc/sddm.conf \n
#	sed -i 's/User=/User=vincentnam/g' /etc/sddm.conf \n
	sed -i 's/Session=/Session=\/usr\/share\/xsessions\/plasma.desktop/g' /etc/sddm.conf \n
	systemctl enable sddm\n
	printf \"setxkbmap fr\" >> /usr/share/sddm/scripts/Xsetup \n
	pacman --noconfirm -S ttf-dejavu" > /mnt/config.sh

wait
arch-chroot /mnt sh +x /config.sh


wait
# Written by systemd-localed(8), read by systemd-localed and Xorg. It's
# probably wise not to edit this file manually. Use localectl(1) to
# instruct systemd-localed to update it.
#Section "InputClass"
 #       Identifier "system-keyboard"
  #      MatchIsKeyboard "on"
   #     Option "XkbLayout" "fr"
#EndSection
#Section "Monitor"
 #      Identifier	"Monitor0"
  #     Option		"DPI" "146.86 x 146.86"
#EndSection 
