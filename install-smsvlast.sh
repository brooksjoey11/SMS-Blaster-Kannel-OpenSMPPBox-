#!/bin/bash

# Update system and install dependencies
apt update && apt upgrade -y
apt install -y build-essential libmysqlclient-dev libxml2-dev git wget php-cli php-curl

# Install Kannel from source
cd /usr/src
git clone https://github.com/kannel/kannel.git
cd kannel
./configure --with-mysql --prefix=/usr/local/kannel
make && make install

# Install opensmppbox from GitHub
cd /usr/src
git clone https://github.com/louney/opensmppbox.git
cd opensmppbox
./configure --with-kannel-dir=/usr/local/kannel
make && make install

# Create Kannel configuration
cat << 'EOF' > /etc/kannel.conf
group = core
admin-port = 13000
smsbox-port = 13001
admin-password = secretpassword
log-file = /var/log/kannel/kannel.log
log-level = 0

group = smsc
smsc = smpp
smsc-id = carrier1
host = smpp.carrier.com
port = 2775
smsc-username = user
smsc-password = pass
system-type = ""
throughput = 50
reconnect-delay = 5
max-pending-submits = 10000

group = smsbox
bearerbox-host = 127.0.0.1
sendsms-port = 13013
global-sender = "TESTSMS"
log-file = /var/log/kannel/smsbox.log
log-level = 0

group = smppbox
smppbox-id = smppblast
bearerbox-host = 127.0.0.1
smppbox-port = 2345
log-file = /var/log/kannel/smppbox.log
log-level = 0
queue-limit = 500000
EOF

# Create directories and set permissions
mkdir -p /var/log/kannel
chown -R kannel:kannel /var/log/kannel || useradd -r kannel && chown -R kannel:kannel /var/log/kannel
chmod 660 /etc/kannel.conf

# Create PHP loader script
cat << 'EOF' > /opt/loader.php
<?php
\$url = "http://example.com/numbers.txt";
\$numbers = file_get_contents(\$url);
if (\$numbers === false) die("Failed to fetch numbers");

\$number_list = array_filter(array_map('trim', explode("\n", \$numbers)));

function send_sms(\$number, \$message = "Test SMS") {
    \$url = "http://127.0.0.1:13013/cgi-bin/sendsms?username=user&password=pass&to=" . urlencode(\$number) . "&text=" . urlencode(\$message);
    \$ch = curl_init(\$url);
    curl_setopt(\$ch, CURLOPT_RETURNTRANSFER, true);
    \$result = curl_exec(\$ch);
    curl_close(\$ch);
    return \$result;
}

\$queue = new SplQueue();
foreach (\$number_list as \$num) {
    \$queue->enqueue(\$num);
}

\$rate = 50;
while (!\$queue->isEmpty()) {
    \$start = microtime(true);
    for (\$i = 0; \$i < \$rate && !\$queue->isEmpty(); \$i++) {
        \$number = \$queue->dequeue();
        send_sms(\$number);
    }
    \$elapsed = microtime(true) - \$start;
    if (\$elapsed < 1) usleep((1 - \$elapsed) * 1000000);
}

echo "SMS blasting completed.\n";
?>
EOF

# Set up systemd service
cat << 'EOF' > /etc/systemd/system/smsblast.service
[Unit]
Description=High-Volume SMS Blasting Service
After=network.target

[Service]
ExecStart=/usr/bin/php /opt/loader.php
Restart=always
User=kannel

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
systemctl daemon-reload
systemctl enable smsblast.service
systemctl start smsblast.service

# Start Kannel services
/usr/local/kannel/sbin/bearerbox /etc/kannel.conf &
/usr/local/kannel/sbin/smsbox /etc/kannel.conf &
/usr/local/kannel/sbin/smppbox /etc/kannel.conf &

echo "SMS blasting system installed and running."
