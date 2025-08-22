# Radicale + InfCloud Docker Container (Single Process)

A complete, ready-to-deploy Docker container that combines:

- **Radicale** - CalDAV and CardDAV server
- **InfCloud** - Full-featured CalDAV/CardDAV web client interface

**Perfect for Portainer deployments!** This is a simplified, single-process container that runs everything through Radicale's built-in web server.

## Features

- 🚀 **Zero-configuration deployment** - Works out of the box
- 🔒 **Secure by default** - Bcrypt password hashing, CORS headers
- 🌐 **Web interface** - InfCloud (100% JavaScript CalDAV/CardDAV client) served directly by Radicale
- 📱 **Mobile compatible** - Works with calendar and contact apps on all platforms
- 🔄 **Auto-builds** - GitHub Actions automatically build and publish to Docker Hub
- 🏥 **Health checks** - Built-in health monitoring
- 📊 **Logging** - Comprehensive logging with rotation
- 🔧 **Configurable** - Easy to customize via volume mounts
- 🐳 **Portainer friendly** - Single process, single port design
- 💾 **Lightweight** - No nginx or supervisord overhead

## Quick Start

### Using Portainer (Recommended for GUI management)

1. **In Portainer**: Go to **Stacks** → **Add Stack**
2. **Name**: `radicale-infcloud`
3. **Web editor**: Copy the docker-compose.yml content below
4. **Deploy the stack**

### Using Docker Compose

```yaml
version: "3.8"

services:
  radicale-infcloud:
    image: yourusername/radicale-infcloud:latest
    container_name: radicale
    ports:
      - "5232:5232" # Radicale CalDAV/CardDAV + InfCloud web interface
    volumes:
      - ./data:/var/lib/radicale/collections
      - ./config/users:/etc/radicale/users
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5232/.web/"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Using Docker Run

```bash
docker run -d \\
  --name radicale \\
  -p 5232:5232 \\
  -v $(pwd)/data:/var/lib/radicale/collections \\
  -v $(pwd)/config/users:/etc/radicale/users \\
  --restart unless-stopped \\
  yourusername/radicale-infcloud:latest
```

## Initial Setup

### 1. Create Users File

Create a users file for authentication:

```bash
# Create config directory
mkdir -p config

# Generate a password hash
python3 -c "import bcrypt; print('admin:' + bcrypt.hashpw(b'your-password', bcrypt.gensalt()).decode())" > config/users
```

Or manually create `config/users`:

```
admin:$2b$12$xyz...hash...abc
user2:$2b$12$abc...hash...xyz
```

### 2. Start the Container

```bash
docker-compose up -d
```

### 3. Access the Services

- **Web Interface (InfCloud)**: http://localhost:5232/.web/
- **CalDAV/CardDAV Server**: http://localhost:5232/
- **Health Check**: http://localhost:5232/.web/

## Usage

### Web Interface

1. Open http://localhost:5232/.web/ in your browser
2. Enter your username and password
3. Create calendars and address books
4. Manage events and contacts through the full InfCloud interface
5. Use drag & drop to organize events and contacts
6. Access multiple calendars and address books
7. Enjoy full calendar/contact management features

### CalDAV/CardDAV Clients

Configure your calendar/contact applications with:

- **Server URL**: `http://your-server:5232/`
- **Username**: Your configured username
- **Password**: Your configured password

#### Popular Client URLs:

- **Calendars**: `http://your-server:5232/username/calendar-name/`
- **Contacts**: `http://your-server:5232/username/addressbook-name/`

### Mobile Apps

#### iOS/macOS

1. Settings → Calendar → Accounts → Add Account → Other
2. Add CalDAV Account:
   - Server: `http://your-server:5232`
   - Username: your-username
   - Password: your-password

#### Android

Use apps like:

- DAVx⁵ (recommended)
- CardDAV-Sync
- CalDAV-Sync

## Configuration

### Custom Configuration

You can override the default configuration by mounting custom config files:

```yaml
volumes:
  - ./config/radicale.conf:/etc/radicale/config
  - ./config/infcloud-config.js:/var/lib/radicale/web/config.js
```

### Environment Variables

The container supports these environment variables:

```bash
# Set in docker-compose.yml
environment:
  - RADICALE_LOG_LEVEL=info
  - NGINX_WORKER_PROCESSES=auto
```

### Volume Mounts

| Path                            | Description               |
| ------------------------------- | ------------------------- |
| `/var/lib/radicale/collections` | Calendar and contact data |
| `/etc/radicale/users`           | User authentication file  |
| `/etc/radicale/config`          | Radicale configuration    |
| `/var/lib/radicale/web/config.js` | InfCloud configuration    |
| `/var/log/radicale`             | Radicale logs             |

## GitHub Actions Setup

To enable automatic Docker Hub publishing:

### 1. Create Docker Hub Secrets

In your GitHub repository settings, add these secrets:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub access token

### 2. Push Changes

The workflow automatically:

- Builds on every push to `main`
- Creates multi-architecture images (amd64, arm64)
- Tags with version numbers and `latest`
- Runs security scans
- Tests the built image

## Security

### Password Security

- Uses bcrypt for password hashing
- Supports strong password policies
- Masks passwords in logs

### Network Security

- CORS headers configured
- Security headers enabled
- Health check endpoints
- Single process security

### Generate Secure Passwords

```bash
# Generate a secure password hash
python3 -c "
import bcrypt
import getpass
password = getpass.getpass('Enter password: ')
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
print(f'username:{hashed.decode()}')
"
```

## Backup and Restore

### Backup

```bash
# Backup data
docker exec radicale tar -czf /tmp/backup.tar.gz -C /var/lib/radicale/collections .
docker cp radicale:/tmp/backup.tar.gz ./backup-$(date +%Y%m%d).tar.gz

# Backup configuration
cp -r config/ backup-config-$(date +%Y%m%d)/
```

### Restore

```bash
# Restore data
docker cp ./backup.tar.gz radicale:/tmp/
docker exec radicale tar -xzf /tmp/backup.tar.gz -C /var/lib/radicale/collections
docker exec radicale chown -R radicale:radicale /var/lib/radicale/collections
```

## Troubleshooting

### Common Issues

1. **Permission Denied**

   ```bash
   docker exec radicale chown -R radicale:radicale /var/lib/radicale
   ```

2. **Can't Access Web Interface**

   - Check if port 5232 is available
   - Access web interface at: http://localhost:5232/.web/
   - Verify container is running: `docker ps`
   - Check logs: `docker logs radicale`

3. **Authentication Failed**
   - Verify users file format
   - Check password hash generation
   - Review Radicale logs

### Logs

```bash
# Container logs
docker logs radicale

# Radicale specific logs
docker exec radicale tail -f /var/log/radicale/radicale.log
```

### Health Check

```bash
# Manual health check
curl http://localhost:5232/.web/
curl http://localhost:5232/
```

## Advanced Configuration

### SSL/TLS Support

For production, use a reverse proxy like Traefik or add SSL certificates:

```yaml
version: "3.8"

services:
  radicale-infcloud:
    image: yourusername/radicale-infcloud:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.radicale.rule=Host(`cal.yourdomain.com`)"
      - "traefik.http.routers.radicale.tls.certresolver=letsencrypt"
    networks:
      - traefik

networks:
  traefik:
    external: true
```

### LDAP Authentication

To use LDAP authentication, mount a custom Radicale config:

```ini
[auth]
type = ldap
ldap_url = ldap://your-ldap-server
ldap_base = ou=users,dc=example,dc=com
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Test with the provided Docker setup
5. Submit a pull request

## License

This project is released under the [Unlicense](LICENSE) - see the LICENSE file for details.

## Support

- 📖 **Documentation**: [Radicale Documentation](https://radicale.org/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/radicale-infcloud/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/radicale-infcloud/discussions)

---

## Architecture

```
┌─────────────────┐    ┌──────────────────┐
│   Web Browser   │    │  CalDAV/CardDAV  │
│   (InfCloud)    │    │     Clients      │
└─────────┬───────┘    └─────────┬────────┘
          │                      │
          │ HTTP :5232/.web/     │ HTTP :5232/
          │                      │
          └──────────────────────▼───────────┐
                                             │
                   ┌─────────────────────────▼──┐
                   │         Radicale           │
                   │   (CalDAV/CardDAV/Web)     │
                   │   + InfCloud Interface     │
                   └────────────────────────────┘
```

Perfect for personal cloud setups, small teams, or anyone wanting a self-hosted calendar and contacts solution! 🎉

## About InfCloud

**InfCloud** is a mature, stable CalDAV/CardDAV web client from [inf-it.com](https://inf-it.com/open-source/clients/infcloud/) that provides:

- 100% JavaScript+jQuery implementation
- Full RFC compliant CalDAV/CardDAV support
- Tested compatibility with Radicale (>=0.8)
- Multi-language support (15+ languages)
- Clean SVG-based user interface
- Drag & drop functionality
- Full calendar and contact management
- Event creation, editing, and scheduling
- Contact management with groups
- Multiple calendar/addressbook support

While InfCloud's last release was in 2015 (v0.13.1), it remains a reliable and feature-complete solution for CalDAV/CardDAV web access.

**Browser Compatibility:** Safari/Mobile Safari, Webkit, iCab, Firefox, Opera (15+), and Chrome. Note: Internet Explorer is not supported.

## Portainer Deployment Guide

This container is specifically designed for easy Portainer deployment:

### 1. In Portainer Dashboard

1. Navigate to **Stacks** → **Add Stack**
2. Choose **Web editor**
3. Name your stack: `radicale-infcloud`

### 2. Stack Configuration

```yaml
version: "3.8"

services:
  radicale-infcloud:
    image: yourusername/radicale-infcloud:latest
    container_name: radicale
    ports:
      - "5232:5232"
    volumes:
      - radicale_data:/var/lib/radicale/collections
    environment:
      - TZ=UTC
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5232/.web/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  radicale_data:
```

### 3. Deploy & Access

1. Click **Deploy the stack**
2. Wait for container to start (check health status)
3. Access at: `http://your-server-ip:5232/.web/`

### 4. Create First User

Using Portainer's console:

1. Go to **Containers** → **radicale** → **Console**
2. Connect with `/bin/bash`
3. Run: `python3 /usr/local/bin/create-user.py`

Or manually create users file:

```bash
echo "admin:$(python3 -c 'import bcrypt; print(bcrypt.hashpw(b\"yourpassword\", bcrypt.gensalt()).decode())')" >> /etc/radicale/users
```

### Benefits for Portainer Users

- ✅ **Single container** - No complex multi-service setup
- ✅ **Single port** - Easy port management
- ✅ **Health checks** - Visual health status in Portainer
- ✅ **Volume management** - Easy backup through Portainer
- ✅ **Log access** - View logs directly in Portainer interface
- ✅ **Resource monitoring** - CPU/RAM usage visible in dashboard
