#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
	exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# Making .config and Moving config files and background to Pictures
cd $builddir
mkdir -p /home/$username/.config
mkdir -p /home/$username/.fonts
mkdir -p /home/$username/Pictures
mkdir -p /home/$username/Pictures/backgrounds
cp -R dotconfig/* /home/$username/.config/
cp bg.jpg /home/$username/Pictures/backgrounds/
mv user-dirs.dirs /home/$username/.config
git clone https://github.com/LazyVim/starter /home/$username/.config/nvim
echo "exec dwm" >/home/$username/.xsession

chown -R $username:$username /home/$username

# Installing Essential Programs
nala install feh kitty rofi picom thunar nitrogen lxpolkit x11-xserver-utils unzip wget pulseaudio pavucontrol build-essential libx11-dev libxft-dev libxinerama-dev -y
# Installing Other less important Programs
nala install neofetch flameshot psmisc mangohud vim lxappearance papirus-icon-theme lxappearance fonts-noto-color-emoji lightdm -y

# Download Nordic Theme
cd /usr/share/themes/
git clone https://github.com/EliverLara/Nordic.git

# Installing fonts
cd $builddir
nala install fonts-font-awesome -y
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
unzip FiraCode.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /home/$username/.fonts
mv dotfonts/fontawesome/otfs/*.otf /home/$username/.fonts/
chown $username:$username /home/$username/.fonts/*

# Reloading Font
fc-cache -vf
# Removing zip Files
rm ./FiraCode.zip ./Meslo.zip

# Install Nordzy cursor
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors
./install.sh
cd $builddir
rm -rf Nordzy-cursors

# Install brave-browser
nala install apt-transport-https curl -y
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
nala update
nala install brave-browser -y

# Install dmenu-distrotube
git clone https://gitlab.com/dwt1/dmenu-distrotube
cd dmenu-distrotube
make install
cd $builddir
rmdir dmenu-distrotube

# Install dwm-jeremy
nala install libimlib2-dev libx11-xcb-dev libxcb-res0-dev -y

git clone https://github.com/pdxpuma/dwm-jeremy
cd dwm-jeremy
make install
cd $builddir
rmdir dwm-jeremy

# TODO sound

# TODO flatpak and enable
nala install flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# TODO neovim + lazynvim
nala install ninja-build gettext cmake unzip curl ripgrep fd-find npm nodejs -y
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
make install
cd $builddir
rmdir neovim

# TODO vscode

# TODO ghcli
type -p curl >/dev/null || (nala update && nala install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
	chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
	nala update &&
	nala install gh -y

# TODO distrobox
#

# Enable graphical login and change target from CLI to GUI
systemctl enable lightdm
systemctl set-default graphical.target

echo "Reboot to enter the new system"
