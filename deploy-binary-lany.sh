#!/bin/bash

# Script to deploy a python program on a binary lane instance

# Make a new user
read -p "Enter the username of the new user: " username
# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "User $username already exists."
    exit 1
fi
read -s -p "Enter the password of the new user: " password
useradd -m -s /bin/bash -c "Binary Lane User" $username
echo -e "$password\n$password" | passwd "$username"
# Add user to sudo group
usermod -aG sudo $username
# switch to user
su - $username

# Install the latest version of python
sudo apt-get update
sudo apt-get upgrade python3
