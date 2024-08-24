#!/bin/bash

# Function to get the IP address and subnet mask
get_network_info() {
    # Try to get the default interface
    interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [ -z "$interface" ]; then
        echo "Error: Could not determine the default network interface." >&2
        exit 1
    fi

    # Get IP address and subnet mask
    ip_info=$(ip -f inet addr show $interface | grep -Po 'inet \K[\d.]+/\d+')
    
    if [ -z "$ip_info" ]; then
        echo "Error: Could not determine IP address and subnet mask." >&2
        exit 1
    fi

    echo $ip_info
}

# Function to calculate network address
calculate_network() {
    IFS='/' read -r ip mask <<< "$1"
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    
    # Convert IP to binary
    ip_bin=$(printf "%08d%08d%08d%08d" $(bc <<< "obase=2;$i1") $(bc <<< "obase=2;$i2") $(bc <<< "obase=2;$i3") $(bc <<< "obase=2;$i4"))
    
    # Calculate network address
    network_bin=${ip_bin:0:$mask}$(printf "%0$((32-$mask))d")
    
    # Convert network address back to decimal
    network=$(echo "ibase=2;obase=A;${network_bin:0:8}" | bc).$(echo "ibase=2;obase=A;${network_bin:8:8}" | bc).$(echo "ibase=2;obase=A;${network_bin:16:8}" | bc).$(echo "ibase=2;obase=A;${network_bin:24:8}" | bc)
    
    echo $network
}

# Get network info and calculate subnet
network_info=$(get_network_info)
subnet=$(calculate_network $network_info)

echo "Detected subnet: $subnet"

# Function to update the displayed IP address
update_ip_display() {
    echo -ne "\rScanning IP: $1     "
}

# Array to store results
declare -a results

# Function to display results
display_results() {
    echo
    echo "Scan results:"
    printf "%-15s %-s\n" "IP Address" "Hostname"
    printf "%-15s %-s\n" "----------" "--------"
    for result in "${results[@]}"; do
        printf "%-15s %-s\n" $result
    done
}

# Function to handle Ctrl+C
ctrl_c() {
    echo
    echo "Scan interrupted. Displaying results found so far:"
    display_results
    exit 1
}

# Set up the interrupt handler
trap ctrl_c INT

# Extract the first three octets of the subnet
subnet_prefix=$(echo $subnet | cut -d. -f1-3)

# Loop through all possible IP addresses in the /24 subnet
for i in {1..254}; do
    ip="${subnet_prefix}.${i}"
    
    update_ip_display "$ip"
    
    # Use ping to check if the IP is responsive
    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        # Attempt to resolve hostname
        hostname=$(getent hosts "$ip" | awk '{print $2}')
        
        # If hostname resolution fails, set hostname to "N/A"
        if [ -z "$hostname" ]; then
            hostname="N/A"
        fi
        
        # Add the result to our array
        results+=("$ip $hostname")
    fi
done

# Print a newline after the scanning is complete
echo

# Display the final results
echo "Scan completed:"
display_results