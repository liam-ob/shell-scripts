#!/bin/bash

# Define the subnet to scan
subnet="10.11.11"

# Function to update the displayed IP address
update_ip_display() {
    echo -ne "\rScanning IP: $1     "
}

# Array to store results
declare -a results

# Loop through all possible IP addresses in the /24 subnet
for i in {1..254}; do
    ip="${subnet}.${i}"
    
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

# Function to display results
display_results() {
    printf "%-15s %-s\n" "IP Address" "Hostname"
    printf "%-15s %-s\n" "----------" "--------"
    for result in "${results[@]}"; do
        printf "%-15s %-s\n" $result
    done
}

# Display the results
echo "Scan completed:"
display_results