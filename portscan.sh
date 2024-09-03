#!/bin/bash

# Function to handle Ctrl+C
ctrl_c() {
    echo -e "\n\nScript interrupted. Printing current results:"
    print_results
    exit 1
}

# Function to print results
print_results() {
    if [ ${#open_ports[@]} -eq 0 ]; then
        echo "No open ports found yet"
    else
        echo "Open ports found so far:"
        for port in "${open_ports[@]}"; do
            echo $port
        done
    fi
}

# Set up the Ctrl+C trap
trap ctrl_c INT

# Check if an IP address is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <ip_address> [start_port] [end_port]"
    exit 1
fi

IP=$1
START_PORT=${2:-1}
END_PORT=${3:-65535}

echo "Scanning $IP for open ports from $START_PORT to $END_PORT"

# Function to update the displayed port number
update_port_display() {
    echo -ne "\rScanning port: $1    " # The extra spaces are for overwriting longer numbers
}

# Array to store open ports
open_ports=()

for PORT in $(seq $START_PORT $END_PORT); do
    update_port_display $PORT
    if nc -z -w1 $IP $PORT 2>/dev/null; then
        open_ports+=($PORT)
    fi
done

echo -e "\nScan complete"

# Display open ports
print_results

