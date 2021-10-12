
read -p "Do you wish to install yay, this is needed for pretty puch everything else so if the answer is no the program will terminate? [y/n](default:n)" USEYAY
if ["$USEPYAY" == "y"] | ["$USEYAY" = "Y"]; then
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  echo "Yay installed"
else 
  exit
fi
rm archsetup.sh