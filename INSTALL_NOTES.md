# CVAT Installation Summary

## Installation Status: ✅ SUCCESSFUL

CVAT has been successfully installed and is running with Docker Compose.

## Configuration

- **CVAT Host**: dipta-ai-cvat.demoin.id
- **Access Port**: 8081 (local Docker), 443 (via Cloudflare Tunnel)
- **Access URL**: https://dipta-ai-cvat.demoin.id (via Cloudflare Tunnel)
- **Local Access**: http://localhost:8081

## Important: Add Hostname to /etc/hosts

To access CVAT using the custom hostname, you need to add it to your `/etc/hosts` file:

### Option 1: Use the provided script (requires sudo)
```bash
sudo bash add-host.sh
```

### Option 2: Manually add the entry
```bash
echo "127.0.0.1 dipta-ai-cvat.demoin.id" | sudo tee -a /etc/hosts
```

## Accessing CVAT

### Via Cloudflare Tunnel (Recommended)
1. **Open your browser** and navigate to: https://dipta-ai-cvat.demoin.id
2. **Create your admin account** on first access

### Via Local Access
1. **Add the hostname to /etc/hosts** (see above)
2. **Open your browser** and navigate to: http://localhost:8081
3. **Create your admin account** on first access

## Docker Compose Commands

- **Start CVAT**: `CVAT_HOST=dipta-ai-cvat.demoin.id docker compose up -d`
- **Stop CVAT**: `docker compose down`
- **View logs**: `docker compose logs -f`
- **Check status**: `docker compose ps`

## Running Containers

All 18 containers are running:
- cvat_server (Main application server)
- cvat_ui (Web interface)
- cvat_db (PostgreSQL database)
- cvat_redis_inmem (Redis in-memory cache)
- cvat_redis_ondisk (Redis persistent cache)
- cvat_clickhouse (Analytics database)
- cvat_opa (Policy engine)
- cvat_grafana (Analytics dashboard)
- cvat_vector (Log aggregation)
- traefik (Reverse proxy)
- 8 worker containers (for various background tasks)

## Port Configuration

- **Main application**: Port 8081 (mapped from container port 8080)
- **Grafana dashboard**: Port 8090

Note: Port 8080 was already in use on your system, so we configured CVAT to use port 8081 instead.

## Modified Files

- `docker-compose.yml`:
  - Updated traefik port mapping from 8080 to 8081
  - Added CSRF trusted origins configuration for Cloudflare Tunnel:
    - CVAT_UI_SCHEME: 'https' (for Cloudflare Tunnel SSL termination)
    - CVAT_UI_HOST: dipta-ai-cvat.demoin.id
    - CVAT_UI_PORT: '' (empty, uses standard HTTPS port 443)

## Next Steps

1. Add hostname to /etc/hosts (run `sudo bash add-host.sh`)
2. Access CVAT at http://dipta-ai-cvat.demoin.id:8081
3. Create your admin user account
4. Start annotating!

## Troubleshooting

If you can't access CVAT:
1. Ensure hostname is added to /etc/hosts
2. Check all containers are running: `docker compose ps`
3. Check logs: `docker compose logs cvat_server`
4. Verify port 8081 is accessible: `curl http://localhost:8081`

For more information, visit: https://docs.cvat.ai/
