#!/bin/bash

echo "Wrong inputs might break the script, be careful!"

timedatectl set-ntp true

read -p "Please output keyboard setup, if not sure output us: " KEYBOARD
loadkeys $KEYBOARD

echo "Please partion according to you boot type "
cfdisk

if [ -d /sys/firmware/efi ]; then
  BOOT_TYPE="uefi";
else
  BOOT_TYPE="bios";
fi

echo "Please output the name of your partitions [/dev/{name}{nr}]: "
read -p "Filesystem partition: " FILESYSTEM
read -p "SWAP partition: " SWAPPART
read -p "BOOT partition: " BOOTPART

mkfs.ext4 $FILESYSTEM 
mkswap $SWAPPART
mkfs.fat -F32 $BOOTPART

mount $FILESYSTEM /mnt
if [! -d /mnt/boot]; then
  mkdir /mnt/boot
fi
mount $BOOTPART /mnt/boot
swapon $SWAPPART

pacstrap /mnt base linux linux-firmware base-devel
genfstab -U /mnt >> /mnt/etc/fstab

read -p "Please output timezone Region: " REGION
read -p "Please output timezone City: " CITY

arch-chroot /mnt ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
arch-chroot /mnt hwclock --systohc

read -p "Please output LOCALE, if not sure output en_US.UTF-8: " LOCALE
sed -i "s/#$LOCALE/$LOCALE/g" /etc/locale.gen
sed -i "s/#$LOCALE/$LOCALE/g" /mnt/etc/locale.gen
locale-gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" >> /mnt/etc/locale.conf
echo "KEYMAP=$KEYBOARD" >> /mnt/etc/vsconsole.conf

read -p "Please output hostname: " HOSTNAME

echo "$HOSTNAME" >> /mnt/etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 $HOSTNAME" >> /mnt/etc/hosts
echo "Setup password: "
passwd


arch-chroot /mnt pacman -S grub
if [ "$BOOT_TYPE"=="uefi" ]; then
  arch-chroot /mnt pacman -S efibootmgr
  arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot
else
  read -p "Please output device, like [/dev/{name}]: " DEVICE
  arch-chroot /mnt grub-install --target=i386-pci $DEVICE
fi
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt reboot
exit