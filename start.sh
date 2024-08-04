#!/bin/sh

echo 'Starting up Tailscale...'

# Load the xt_mark module for marking packets
modprobe xt_mark

# Enable IPv4 and IPv6 forwarding
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Configure NAT for IPv4 and IPv6
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Start tailscaled with userspace networking
/app/tailscaled --tun=userspace-networking --verbose=1 --port 41641 &
sleep 5

if [ ! -S /var/run/tailscale/tailscaled.sock ]; then
    echo "tailscaled.sock does not exist. exit!"
    exit 1
fi

# Attempt to bring up Tailscale interface
until /app/tailscale up \
    --login-server=${HS} \
    --authkey=${TS_AUTHKEY} \
    --hostname=${TS_HOSTNAME} \
    --netfilter-mode=off \
    --state=/tailscale/state
do
    sleep 0.1
done

echo 'Tailscale started'

echo 'Starting Squid...'
squid &
echo 'Squid started'

echo 'Starting Dante...'
sockd &
echo 'Dante started'

echo 'Starting dnsmasq...'
dnsmasq &
echo 'Dnsmasq started'

echo 'Starting Caddy...'
caddy run --config /caddy/caddyfile --adapter caddyfile &
echo 'Caddy started'

sleep infinity
