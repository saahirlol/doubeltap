#!/bin/sh

echo 'Starting up Tailscale...'

# error: adding [-i tailscale0 -j MARK --set-mark 0x40000] in v4/filter/ts-forward: running [/sbin/iptables -t filter -A ts-forward -i tailscale0 -j MARK --set-mark 0x40000 --wait]: exit status 2: iptables v1.8.6 (legacy): unknown option "--set-mark"
modprobe xt_mark

echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
#echo 'net.ipv6.conf.all.disable_policy = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE



# Start tailscaled
/app/tailscaled --verbose=1 --port 41641 &
sleep 5

if [ ! -S /var/run/tailscale/tailscaled.sock ]; then
    echo "tailscaled.sock does not exist. exit!"
    exit 1
fi

until /app/tailscale up \
    --login-server=${HS} \
    --authkey=${TS_AUTHKEY} \
    --hostname=${TS_HOSTNAME} \
    --tun=userspace-networking \
    --state=/tailscale/state  \
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

echo 'Starting caddy...'

caddy run --config /caddy/caddyfile --adapter caddyfile  &

echo 'Caddy started'

sleep infinity
