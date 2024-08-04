#!/bin/sh

echo 'Starting up Tailscale...'

# Enable IPv4 and IPv6 forwarding
echo 'Enabling IP forwarding...'
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Configure NAT for IPv4 and IPv6
echo 'Configuring NAT...'
if iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; then
    echo "IPv4 NAT configured successfully."
else
    echo "Failed to set IPv4 NAT. Are iptables installed and configured correctly?"
fi

if ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; then
    echo "IPv6 NAT configured successfully."
else
    echo "Failed to set IPv6 NAT. Are ip6tables installed and configured correctly?"
fi

# Start tailscaled with userspace networking
echo 'Starting tailscaled...'
if /app/tailscaled --tun=userspace-networking --verbose=1 --port 41641 & then
    echo "tailscaled started successfully."
else
    echo "Failed to start tailscaled."
    exit 1
fi

sleep 5

# Check for tailscaled socket
if [ ! -S /var/run/tailscale/tailscaled.sock ]; then
    echo "tailscaled.sock does not exist. exit!"
    exit 1
fi

# Attempt to bring up Tailscale interface
echo 'Bringing up Tailscale interface...'
until /app/tailscale up \
    --login-server="${HS}" \
    --authkey="${TS_AUTHKEY}" \
    --hostname="${TS_HOSTNAME}" \
    --netfilter-mode=off; do
    echo "Retrying Tailscale up..."
    sleep 1
done

echo 'Tailscale started successfully.'

echo 'Starting Squid...'
if squid & then
    echo "Squid started successfully."
else
    echo "Failed to start Squid."
    exit 1
fi

echo 'Starting Dante...'
if sockd & then
    echo "Dante started successfully."
else
    echo "Failed to start Dante."
    exit 1
fi

echo 'All services started successfully.'
sleep infinity
