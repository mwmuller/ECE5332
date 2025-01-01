#!/bin/bash

# Upgrade System
echo "Updating and installing Ubuntu and ROS"
sudo apt dist-upgrade -y
sudo apt update
sudo apt dist-upgrade -y

# Install ROS and Git
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'
curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -
sudo apt update
sudo apt install -y ros-noetic-desktop python3-rosdep
ROS_VERSION="noetic"

echo "source /opt/ros/${ROS_VERSION}/setup.bash" >> $HOME/.bashrc

source $HOME/.bashrc
sudo rosdep init
rosdep update

# Install VS Code
sudo snap install --classic code

# Set up ROS helper scripts
cd $HOME
git clone https://github.com/robustify/ros_helper_scripts.git
echo "export PATH=\$HOME/ros_helper_scripts/:\$PATH" >> $HOME/.bashrc

# Download and install binaries of code for the course
# Create temporary directory
dir=`mktemp -d`
cd $dir
echo "Installing ECE 5532 course support packages"

wget -O ugv_${ROS_VERSION}_release_latest.tar.gz "ftp://ftp@199.244.49.111/pub/ugv_noetic_release_latest.tar.gz"
mkdir -p ugv_${ROS_VERSION}_release
tar -xf ugv_${ROS_VERSION}_release_latest.tar.gz -C ./ugv_${ROS_VERSION}_release
sudo dpkg -i ugv_${ROS_VERSION}_release/*.deb
sudo apt install -f -y
sudo dpkg -i ugv_${ROS_VERSION}_release/*.deb
sudo apt install -f -y

source $HOME/.bashrc

# Download VS Code settings and put in the appropriate folders
echo "Downloading and setting up VS Code settings"
wget -O vs_code_settings.tar.gz "ftp://ftp@199.244.49.111/pub/vs_code_settings.tar.gz"
mkdir -p vs_code_settings
tar -xf vs_code_settings.tar.gz -C ./vs_code_settings
mkdir -p $HOME/.config/Code/User
mkdir -p $HOME/.vscode/extensions
cp vs_code_settings/settings.json $HOME/.config/Code/User
cp vs_code_settings/keybindings.json $HOME/.config/Code/User
cp -r vs_code_settings/extensions/* $HOME/.vscode/extensions

# Set up ROS workspace
cd $HOME
if [ ! -d ros ]; then
  echo "Initializing ROS workspace"
  mkdir -p ros/src

  cd $HOME/ros
  source /opt/ros/${ROS_VERSION}/setup.bash
  $HOME/ros_helper_scripts/release.bash
  echo "source $HOME/ros/devel/setup.bash" >> $HOME/.bashrc
else
  echo "$HOME/ros already exists... skipping workspace initialization"
fi
