#!/bin/sh

echo 'Starting up Tailscale...'

# Load the xt_mark module for marking packets
if ! modprobe xt_mark; then
    echo "Failed to load xt_mark module."
    exit 1
fi

# Enable IPv4 and IPv6 forwarding
echo 'Enabling IP forwarding...'
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Configure NAT for IPv4 and IPv6
echo 'Configuring NAT...'
if ! iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; then
    echo "Failed to set IPv4 NAT."
    exit 1
fi

if ! ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; then
    echo "Failed to set IPv6 NAT."
    exit 1
fi

# Start tailscaled with userspace networking
echo 'Starting tailscaled...'
if ! /app/tailscaled --tun=userspace-networking --verbose=1 --port 41641 & then
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
    --netfilter-mode=off \
    --state=/tailscale/state
do
    echo "Retrying Tailscale up..."
    sleep 1
done

echo 'Tailscale started successfully.'

echo 'Starting Squid...'
if ! squid & then
    echo "Failed to start Squid."
    exit 1
fi
echo 'Squid started'

echo 'Starting Dante...'
if ! sockd & then
    echo "Failed to start Dante."
    exit 1
fi
echo 'Dante started'

echo 'Starting dnsmasq...'
if ! dnsmasq & then
    echo "Failed to start dnsmasq."
    exit 1
fi
echo 'Dnsmasq started'

echo 'Starting Caddy...'
if ! caddy run --config /caddy/caddyfile --adapter caddyfile & then
    echo "Failed to start Caddy."
    exit 1
fi
echo 'Caddy started'

# Keep script running
sleep infinity
