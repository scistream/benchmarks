# Installation Guide

## Automatic Installation
```bash
sudo ./install.sh
```

## Manual Installation
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

**Note**: Log out and log back in for group changes to take effect.

## Next Steps
```bash
# Build and start environment
docker-compose build
docker-compose up -d
```

For test details, see `tests/README.md`