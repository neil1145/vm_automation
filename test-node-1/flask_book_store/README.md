# Flask Book Store Application with Kubernetes Setup

A containerized Flask application with PostgreSQL backend, deployable via Vagrant and Docker, with Kubernetes support.

## Project Structure
```
/project_root/
├── backend/
│   ├── backend.Dockerfile
│   └── init.sql
├── frontend/
│   ├── templates/
│   │   ├── base.html
│   │   ├── create.html
│   │   └── index.html
│   ├── app.py
│   ├── frontend.Dockerfile
│   └── requirements.txt
├── docker-compose.yml
├── docker-compose-prod.yml
├── Vagrantfile
├── .env
└── README.md
```

## Prerequisites

- VirtualBox (>= 6.1.0)
- Vagrant (>= 2.2.0)
- Docker (>= 20.10.0)
- Docker Compose (>= 2.0.0)

## Quick Start

1. Clone the repository and setup environment:
```bash
# Create .env file
DB_HOST=db
DB_NAME=flask_db
DB_USERNAME=flask_user
DB_PASSWORD=flaskpass        # Password for flask_user
POSTGRES_PASSWORD=pgpass     # Initial PostgreSQL password
FLASK_DEBUG=True
FLASK_SECRET_KEY=your_generated_secret_key
```

2. Start VMs:
```bash
# Start Flask application VM
vagrant up test-node-1

# Start Kubernetes cluster
vagrant up kube-vm kube-node-1 kube-node-2

# Start Ansible controller
vagrant up ansible-vm
```

## Vagrant Operations

### Basic Commands
```bash
# Start specific VM
vagrant up test-node-1

# SSH into VM
vagrant ssh test-node-1

# Stop VM
vagrant halt test-node-1

# Destroy VM
vagrant destroy test-node-1

# Check status
vagrant status
```

### SSH Access
```bash
# Using Vagrant
vagrant ssh test-node-1

# Direct SSH (Using generated keys)
ssh -i .vm_keys/test-node-1/id_rsa -p 27257 vagrant@localhost
```
## VM Keys Management

The project includes a key management script (`vm_keys_manager.sh`) for handling SSH keys securely.

### Key Structure
```
.vm_keys/
├── ansible-vm/
│   ├── id_rsa
│   └── id_rsa.pub
├── kube-vm/
│   ├── id_rsa
│   └── id_rsa.pub
├── kube-node-1/
│   ├── id_rsa
│   └── id_rsa.pub
└── [other VMs...]
```

### Using vm_keys_manager.sh
```bash
# List all VM keys
./vm_keys_manager.sh list

# Backup current keys
./vm_keys_manager.sh backup
# Creates: .vm_keys_backup_YYYYMMDD_HHMMSS/

# Rotate keys for specific VM
./vm_keys_manager.sh rotate kube-vm

# Access VM using managed keys
ssh -i .vm_keys/kube-vm/id_rsa -p 2726 vagrant@localhost
```

### Key Management Operations

1. Initial Setup:
```bash
# Keys are automatically generated when:
vagrant up [vm-name]
# Keys stored in .vm_keys/[vm-name]/
```

2. Key Rotation:
```bash
# Rotate single VM keys
./vm_keys_manager.sh rotate kube-node-1

# Update VM with new keys
vagrant reload kube-node-1
```

3. Backup and Recovery:
```bash
# Create backup
./vm_keys_manager.sh backup

# Recover keys
cp -r .vm_keys_backup_[timestamp]/* .vm_keys/
```

### VM Access After Key Operations

1. After Fresh Setup:
```bash
# Using vagrant
vagrant ssh [vm-name]

# Using generated keys
ssh -i .vm_keys/[vm-name]/id_rsa -p [port] vagrant@localhost
```

2. After Key Rotation:
```bash
# Stop the VM
vagrant halt [vm-name]

# Rotate keys
./vm_keys_manager.sh rotate [vm-name]

# Start VM with new keys
vagrant up [vm-name]
```

Note: The `vm_keys_manager.sh` script manages keys independently of Vagrant, providing an additional layer of security and key management flexibility.

## Docker Operations

### Development Environment
```bash
# Build and start services
docker-compose up --build

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Environment
```bash
# Start production stack
docker-compose -f docker-compose-prod.yml up -d
```

## Application Access

### Flask Application
- Development: http://localhost:5000
- Database: localhost:5432

### Kubernetes Ports
- API Server: 6443
- Kubelet: 10250
- NodePort Range: 30000-32767

## Port Configuration

### Flask Application VM (test-node-1)
- SSH: 27257
- Flask App: 5000
- PostgreSQL: 5432
- Alternative Web: 8080
- Frontend Dev: 3000

### Kubernetes Master (kube-vm)
- SSH: 2726
- API Server: 6443
- etcd: 2379-2380
- Controller Manager: 10257
- Scheduler: 10259

### Kubernetes Workers
- SSH: 2724 (node-1), 2725 (node-2)
- Kubelet: 10250
- NodePort Range: 30000-32767

## Common Operations

### Database Management
```bash
# Connect to database
docker-compose exec db psql -U flask_user -d flask_db

# View database logs
docker-compose logs db
```

### Application Management
```bash
# View application logs
docker-compose logs web

# Restart application
docker-compose restart web
```

## Common Issues and Solutions

1. Port Conflicts:
```bash
# Check port usage
vagrant port test-node-1
```

2. Database Connection Issues:
```bash
# Verify database is running
docker-compose ps db

# Check database logs
docker-compose logs db
```

3. VM Access Issues:
```bash
# List generated SSH keys
ls -l .vm_keys/

# Verify SSH config
vagrant ssh-config test-node-1
```