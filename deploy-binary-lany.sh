#!/bin/bash

# Function to perform cleanup
cleanup() {
    echo "Performing cleanup..."
    # Remove the NOPASSWD sudo permission
    if [ -f "/etc/sudoers.d/$username" ]; then
        rm /etc/sudoers.d/$username
        echo "Removed temporary sudo permissions."
    fi
    # Add any other cleanup tasks here
}

# Set up trap to call cleanup function on script exit (normal or error)
trap cleanup EXIT

# Function to handle errors
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo "Error on line $line_number: Command exited with status $exit_code."
}

# Set up trap to call handle_error function on any command error
trap 'handle_error $LINENO' ERR

# Enable exit on error
set -e

# Script to deploy a python program on a binary lane instance

# Make a new user
read -p "Enter the username of the new user: " username
# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "User $username already exists."
    exit 1
fi
useradd -m -s /bin/bash -c "Binary Lane User" $username
passwd "$username"
# Add user to sudo group
usermod -aG sudo $username

# Configure sudo for the new user to not require password
echo "$username ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$username

# The rest of the script should be executed as the new user
cat <<EOT > /home/$username/deploy_script.sh
#!/bin/bash

# Enable exit on error
set -e

# Function to handle errors
handle_error() {
    local exit_code=\$?
    local line_number=\$1
    echo "Error in deploy_script.sh on line \$line_number: Command exited with status \$exit_code."
}

# Set up trap to call handle_error function on any command error
trap 'handle_error \$LINENO' ERR

# Install the latest version of python
echo "installing python"
sudo apt-get update -qq
sudo apt-get install python3 -y -qq

# Install nginx
echo "Installing nginx"
sudo apt-get install nginx -y -qq

# Install curl
echo "installing curl"
sudo apt-get install curl -y -qq

# Install poetry 
echo "installing poetry"
curl -sSL https://install.python-poetry.org | python3 -
sudo ln -s \$HOME/.local/bin/poetry /usr/bin/poetry 
if command -v poetry &> /dev/null
then
    echo "Poetry is installed."
else
    echo "Poetry is NOT installed!"
    exit 1
fi
poetry config virtualenvs.create false
poetry config virtualenvs.in-project true

# Configure fail2ban
echo "Configuring fail2ban for SSH..."
sudo apt install fail2ban -y -qq

# Configure fail2ban for SSH
sudo tee "/etc/fail2ban/jail.local" > /dev/null <<EOL
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 604800
EOL

# Confirm the file has been created
if [ -f "/etc/fail2ban/jail.local" ]; then
    echo "File created successfully at /etc/fail2ban/jail.local"
else
    echo "Failed to create the file fail2ban conf"
    exit 1
fi

# Restart fail2ban
echo "Restarting fail2ban..."
sudo systemctl restart fail2ban

echo "You can check the status of the SSH jail with: sudo fail2ban-client status sshd"
EOT

# Make the script executable
chmod +x /home/$username/deploy_script.sh

# Switch to the new user and run the script
if ! su - $username -c "/home/$username/deploy_script.sh"; then
    echo "Error: deploy_script.sh failed."
    exit 1
fi

echo "Deployment completed successfully!"