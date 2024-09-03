#!/bin/bash

# Run on a machine behind a inaccessible network (behind NAT) with the IP address to a machine accessible through the internet
# To connect, navigate to the machine outside of the NAT protected netowrk:
# ssh -p <port> user@localhost

ssh -N -R 0.0.0.0:<remote machine port>:localhost:22 -o ExitOnForwardFailure=yes -o ProtocolKeepAlives=5 <IP address>