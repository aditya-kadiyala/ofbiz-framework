# BizWithAI Docker Setup - Running

## Status
✅ Docker containers are running
✅ PostgreSQL is accessible on localhost:5432
✅ BizWithAI (OFBiz) is accessible on https://localhost:8443

## Access BizWithAI
- URL: https://localhost:8443/partymgr
- Username: admin
- Password: ofbiz
- Note: Browser will show security warning (self-signed certificate)

## Branding Changes Applied
✅ Browser titles changed from "OFBiz:" to "BizWithAI:"
✅ Custom UI labels file: framework/common/config/ZZZCustomUiLabels.xml
📝 Favicon: Replace files in themes/common-theme/webapp/images/favicon*

## PostgreSQL Connection
See DB-CONNECTION.txt for full details.
- Host: localhost
- Port: 5432
- Main DB: ofbizmaindb / ofbiz / Ab6SqDD2YM2lmEsvao-

## Commands
```bash
# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Start containers
docker-compose up -d

# Rebuild after code changes
cd ../../..
docker build --tag ofbiz-docker .
cd docker/examples/postgres-demo
docker-compose down
docker-compose up -d
```
