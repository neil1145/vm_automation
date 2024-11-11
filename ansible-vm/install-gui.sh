#!/bin/bash
# update
sudo apt-get update -y

# GUI tools
sudo apt-get install xfce4 virtualbox-guest-utils virtualbox-guest-x11 -y

# Permit anyone to start the GUI
sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config

# Optional: Use LightDM login screen (-> not required to run "startx")
sudo apt-get install -y lightdm lightdm-gtk-greeter

# Optional: Install a more feature-rich applications menu
sudo apt-get install -y xfce4-whiskermenu-plugin