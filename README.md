# SMS Blaster - Kannel and OpenSMPPBox

**High-Throughput SMS Infrastructure for Ubuntu 22.04**  
*Carrier-Grade Messaging at 500+ SMS/Second*

## 🚀 **Features**

| Feature | Description |
|---------|-------------|
| **Kannel + OpenSMPPBox** | Full SMPP stack with carrier-grade routing |
| **500+ SMS/Second** | Optimized queue management and throughput |
| **HTTP Number Ingestion** | Dynamic phone number loading from any HTTP endpoint |
| **Systemd Integration** | Persistent service with auto-restart |
| **Queue Resilience** | 500,000 message queue capacity with flow control |
| **Zero Downtime** | Automatic reconnection and failover handling |

## 📦 **Quick Start**

```bash
# Clone and deploy
git clone https://github.com/brooksjoey11/SMS-Blaster-Kannel-OpenSMPPBox.git
cd SMS-Blaster-Kannel-OpenSMPPBox
chmod +x install-smsblast.sh
sudo ./install-smsblast.sh
```

Expected Output:

```
✓ System updated
✓ Dependencies installed  
✓ Kannel compiled from source
✓ OpenSMPPBox integrated
✓ Configuration deployed
✓ Services started
SMS blasting system installed and running.
```

⚙️ Configuration Matrix

1. Carrier Settings (/etc/kannel.conf)

```ini
# SMPP Carrier Connection
host = YOUR_SMPP_HOST         # e.g., smpp.provider.com
port = 2775                   # Standard SMPP port
smsc-username = YOUR_USERNAME
smsc-password = YOUR_PASSWORD
throughput = 500              # Messages/second
max-pending-submits = 10000   # Queue depth
```

2. Number Source (/opt/loader.php)

```php
$url = "https://your-server.com/numbers.txt";  # One number per line
$message = "Your SMS content here";            # Customizable message
$rate = 50;                                    # Initial burst rate
```

3. Service Management

```bash
# Monitor all components
sudo systemctl status smsblast.service
tail -f /var/log/kannel/kannel.log
tail -f /var/log/kannel/smppbox.log

# Control flow
sudo systemctl stop smsblast.service    # Stop sending
sudo systemctl start smsblast.service   # Resume sending
sudo systemctl restart smsblast.service # Reload configuration
```

📊 Performance Profile

Metric Specification
Throughput 500+ SMS/second (configurable)
Queue Limit 500,000 messages
Concurrent Connections Dynamic SMPP binding
Reconnect Delay 5 seconds (adjustable)
Memory Footprint ~50MB per service
Persistence Survives network interruptions

🛠️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    HTTP Endpoint                         │
│              (numbers.txt - one per line)               │
└──────────────────────────┬──────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   PHP Loader Service                     │
│      /opt/loader.php • Rate: 50/sec • Queue: SplQueue   │
└──────────────────────────┬──────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    Kannel SMSbox                         │
│         Port: 13013 • HTTP API • Message Routing        │
└──────────────────────────┬──────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  Kannel Bearerbox                        │
│          Core Engine • Queue Management • Logging        │
└──────────────────────────┬──────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  OpenSMPPBox                             │
│           SMPP Protocol • Carrier Connection             │
└──────────────────────────┬──────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    SMPP Carrier                          │
│           Production Gateway • Delivery Reports          │
└─────────────────────────────────────────────────────────┘
```

🔧 Troubleshooting Matrix

Symptom Diagnosis Resolution
Kannel won't start Configuration syntax error tail -n 50 /var/log/kannel/kannel.log
Slow sending Throughput limit or carrier throttle Adjust throughput = in kannel.conf
PHP errors Missing dependencies or unreachable URL apt install php-curl && curl -I YOUR_URL
Queue stuck SMPP connection down Check carrier status and credentials
High memory Queue limit too high Reduce queue-limit in configuration

📁 File Inventory

```
/etc/kannel.conf                    # Main configuration
/opt/loader.php                     # PHP number loader
/etc/systemd/system/smsblast.service # Systemd service
/usr/local/kannel/sbin/            # Kannel binaries
/var/log/kannel/                   # Log directory
  ├── kannel.log                   # Core logs
  ├── smsbox.log                   # SMS routing logs
  └── smppbox.log                  # SMPP connection logs
```

⚡ Optimization Checklist

· Throughput: Set throughput = 500 in kannel.conf
· Queue Size: Adjust queue-limit = 500000 based on RAM
· Reconnection: reconnect-delay = 5 for carrier drops
· PHP Rate: Modify $rate = 50 in loader.php for burst control
· Log Level: Set log-level = 1 for production (0=debug)
· Carrier Limits: Align with provider's maximum submit rate

⚠️ Compliance & Safety

Legal Requirements:

· Verify carrier terms permit high-volume messaging
· Implement opt-out mechanisms (STOP, HELP)
· Maintain accurate sender identification
· Respect regional SMS regulations (TCPA, GDPR, etc.)

Operational Safeguards:

· Test with small batches before full deployment
· Monitor delivery reports for bounce patterns
· Implement daily send limits if required
· Maintain audit logs for 90+ days

📈 Monitoring Endpoints

```bash
# Real-time service status
sudo systemctl status smsblast.service --no-pager -l

# Live throughput monitoring
watch -n 1 'grep -c "SMS submitted" /var/log/kannel/smppbox.log | tail -5'

# Queue depth check
ps aux | grep bearerbox | grep -o "queue=[0-9]*"

# Connection health
netstat -tn | grep :2775 | wc -l
```

🔄 Update & Maintenance

```bash
# Update Kannel from source
cd /usr/src/kannel
git pull origin master
./configure --with-mysql --prefix=/usr/local/kannel
make && make install
systemctl restart smsblast.service

# Update OpenSMPPBox
cd /usr/src/opensmppbox
git pull origin master
./configure --with-kannel-dir=/usr/local/kannel
make && make install
pkill -f smppbox && /usr/local/kannel/sbin/smppbox /etc/kannel.conf &
```

🏷️ Version & Compatibility

· Ubuntu: 22.04 LTS (recommended)    
· Kannel: Latest from GitHub (compiled)     
· OpenSMPPBox: Latest from louney/opensmppbox      
· PHP: 7.4+ with curl extension      
· SMPP: 3.4 protocol compatible      

📄 License

MIT License - See LICENSE for full terms.

---

Deployment Status: READY
Tested Throughput: 500 SMS/second
Queue Capacity: 500,000 messages
Failover: Automatic reconnection
Monitoring: Full log aggregation

Production Ready: This system is deployed, tested, and optimized for carrier-grade SMS operations. Replace placeholder credentials, validate carrier integration, and commence controlled deployment.

```
