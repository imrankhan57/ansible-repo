#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

read -p "Enter new superuser username: " username

# Create the user
useradd -m -s /bin/bash "$username"

# Set password
passwd "$username"

# Add user to wheel group for sudo privileges
usermod -aG wheel "$username"

echo "Superuser '$username' created and added to wheel group."