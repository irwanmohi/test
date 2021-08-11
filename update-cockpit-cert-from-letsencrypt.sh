master.aidan.my

echo "create /etc/systemd/system/cockpit.socket.d/listen.conf for run it as daemon on port 443"
cat <<EOF > /etc/systemd/system/cockpit.socket.d/listen.conf
[Socket]
ListenStream= 
ListenStream=9090 
ListenStream=443
EOF

echo "Create cert for cockpit"
cat /etc/letsencrypt/live/master.aidan.my/fullchain.pem > /etc/cockpit/ws-certs.d/1-my-cert.cert
cat /etc/letsencrypt/live/master.aidan.my/privkey.pem >> /etc/cockpit/ws-certs.d/1-my-cert.cert

echo "Restart Daemon:"
echo "systemctl daemon-reload && systemctl restart cockpit.socket"
systemctl daemon-reload && systemctl restart cockpit.socket

echo "Check Cockpit https://$DOMAIN/"
