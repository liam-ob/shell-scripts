#!/bin/bash

# ssh -i "/bbw/bigbadwolf" -R 8022:localhost:22 <user>@<aws instance>

# or do this:

#!/bin/bash

# Set the path to the private key file
PRIVATE_KEY="/bbw/bigbadwolf"

# Set the user and AWS instance details
USER="<user>"
AWS_INSTANCE="<aws_instance>"

# Set the local and remote port numbers
LOCAL_PORT=8022
REMOTE_PORT=22

# Function to establish the reverse SSH tunnel
establish_tunnel() {
    while true; do
        ssh -N -R "${LOCAL_PORT}":localhost:"${REMOTE_PORT}" -i "${PRIVATE_KEY}" "${USER}"@"${AWS_INSTANCE}" \
            && break || sleep 60
    done
}

# Function to handle script termination
terminate() {
    echo "Terminating reverse SSH tunnel..."
    exit 0
}

# Set up signal traps for graceful termination
trap 'terminate' SIGINT SIGTERM

# Log the start of the script
echo "Starting reverse SSH tunnel: ${USER}@${AWS_INSTANCE}:${REMOTE_PORT} -> localhost:${LOCAL_PORT}"

# Establish the reverse SSH tunnel
establish_tunnel

# Wait for the tunnel to be terminated
wait