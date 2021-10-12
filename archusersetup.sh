
read -p "Please output your username: " USERNAME
useradd -m $USERNAME
read -p "Do you want a password? [y/n](default:n)" USEPASS
if ["$USEPASS" == "y"] | ["$USEPASS" = "Y"]; then
  passwd $USERNAME
else 
  passwd -d $USERNAME
fi

usermod -a -G $USERNAME audio video
pacman -S sudo git

cd /home/$USERNAME
curl -sL https://raw.githubusercontent.com/Autron01/archis/archsetup.sh > archsetup.sh

echo "Your user has been setup, please reboot and login :)" 

rm archusersetup.sh