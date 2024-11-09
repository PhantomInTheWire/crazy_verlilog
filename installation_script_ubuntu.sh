#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo to execute the script."
   exit 1
fi

# Update and install required packages
echo "Updating system and installing dependencies..."
apt-get update
apt-get install -y git make autoconf gcc g++ flex bison

# Clone Icarus Verilog repository
echo "Cloning the Icarus Verilog repository..."
git clone https://github.com/steveicarus/iverilog.git
cd iverilog || { echo "Failed to enter iverilog directory."; exit 1; }

# Run autoconf to generate configuration files
echo "Running autoconf.sh to create build files..."
sh autoconf.sh
if [[ $? -ne 0 ]]; then
   echo "Autoconf failed. Installing autoconf..."
   apt-get install -y autoconf
   sh autoconf.sh
   if [[ $? -ne 0 ]]; then
      echo "Autoconf failed again. Please check your setup."
      exit 1
   fi
fi

# Configure the build
echo "Configuring the build with default settings..."
./configure
if [[ $? -ne 0 ]]; then
   echo "Configuration failed. Exiting."
   exit 1
fi

# Compile the source code
echo "Compiling Icarus Verilog. This may take a few minutes..."
make -j"$(nproc)"
if [[ $? -ne 0 ]]; then
   echo "Compilation failed. Please check for errors."
   exit 1
fi

# Install Icarus Verilog
echo "Installing Icarus Verilog..."
make install

# Optional: Install GTKWave for waveform viewing
read -p "Would you like to install GTKWave for waveform viewing? (y/n): " install_gtkwave
if [[ $install_gtkwave == "y" || $install_gtkwave == "Y" ]]; then
   echo "Installing GTKWave..."
   apt-get install -y gtkwave
fi

# Optional: Install yosys for chart viewing
read -p "Would you like to install yosys and graphviz for chart viewing? (y/n): " install_yosys
if [[ $install_yosys == "y" || $install_yosys == "Y" ]]; then
   echo "Installing yosys..."
   apt-get install -y yosys graphviz
fi

echo "Installation complete! You can verify by running 'iverilog -v'."
