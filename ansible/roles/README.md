# Ansible Role: dataiku

Ansible role for installing and configuring Dataiku DSS (Data Science Studio) on Ubuntu.

## Description

This role automates the complete deployment of Dataiku DSS, including all required dependencies, system configuration, and service setup.

It supports Docker integration with multi-image builds (container-exec, CDE, Spark), Google Cloud Platform integration (gcloud CLI, GKE auth plugin, Docker registry authentication, optional monitoring agent), Kubernetes (kubectl), Spark and Hadoop standalone installations, R integration with LibreOffice and Chrome support, graphics export functionality, user namespace configuration, and optional SSL/TLS configuration with Let's Encrypt.

## Requirements

- Ansible 2.9 or higher
- Target system: Ubuntu (tested on Ubuntu 22.04)
- Root or sudo access on target hosts
- Internet connectivity for downloading packages and Dataiku DSS

### System Requirements

- Minimum 8GB RAM (16GB+ recommended for production)
- Minimum 50GB disk space (100GB+ recommended)
- CPU: 4+ cores recommended
- Network access to:
  - cdn.downloads.dataiku.com (Dataiku binaries)
  - download.docker.com (Docker packages)
  - packages.cloud.google.com (GCP tools)
  - dl.k8s.io (kubectl binary)
  - archive.ubuntu.com (system packages)

## Role Variables

### Required Variables

None - all variables have sensible defaults.

### Optional Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

#### Dataiku Installation Settings

```yaml
# Dataiku DSS version to install
dataiku_version: "14.2.0"

# Download URL for Dataiku DSS
dataiku_download_url: "https://cdn.downloads.dataiku.com/public/studio/{{ dataiku_version }}/dataiku-dss-{{ dataiku_version }}.tar.gz"

# Installation directory for Dataiku binaries
dataiku_install_dir: "/opt/dataiku"

# Data directory for Dataiku instance
dataiku_data_dir: "/data/dataiku"

# Dataiku user and group
dataiku_user: "dataiku"
dataiku_group: "dataiku"

# Port for Dataiku web interface
dataiku_port: 10000

# Optional license file path (leave empty if no license)
dataiku_license_file: ""
```

#### Java and Python Settings

```yaml
# Java package to install
java_package: "default-jdk"

# Python version
python_version: "python3.9"
```

#### Additional Packages

```yaml
# Additional system packages to install
dataiku_additional_packages:
  - python3-pip
  - python3-dev
  - build-essential
  - libssl-dev
  - libffi-dev
  - libxml2-dev
  - libxslt1-dev
  - zlib1g-dev
  - nginx
  - acl
  - apt-transport-https
  - ca-certificates
  - curl
  - software-properties-common

# Python packages to install via pip
pip_packages:
  - virtualenv
  - setuptools
  - wheel
```

#### GCP Monitoring Configuration

```yaml
# GCP region for Docker registry authentication
gcp_region: "europe-north1"

# Enable Google Cloud Operations agent installation
use_gcp_monitoring: false

# URL for GCP monitoring agent installation script
gcp_monitoring_agent_url: "https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh"
```

#### Spark and Hadoop Integration

```yaml
# Spark standalone archive URL
dss_spark_standalone: "https://cdn.downloads.dataiku.com/public/dss/{{ dataiku_version }}/dataiku-dss-spark-standalone-{{ dataiku_version }}-3.5.3-generic-hadoop3.tar.gz"

# Hadoop standalone archive URL
dss_hadoop_standalone: "https://cdn.downloads.dataiku.com/public/dss/{{ dataiku_version }}/dataiku-dss-hadoop-standalone-libs-generic-hadoop3-{{ dataiku_version }}.tar.gz"
```

#### Kubernetes and GCP Integration

```yaml
# kubectl version to install
kubectl_version: "v1.33.5"
```

Note: The role automatically installs Google Cloud CLI and GKE authentication plugin during the dependency installation phase.

#### SSL/TLS Configuration

```yaml
# Enable Let's Encrypt SSL certificates
use_letsencrypt: false

# Email for Let's Encrypt registration
letsencrypt_email: ""

# Domain name for SSL certificate
dns_name: ""

# Let's Encrypt packages
letsencrypt_packages:
  - certbot
  - python3-certbot-nginx
```

## Dependencies

This role requires the following Ansible collections:

```yaml
---
collections:
  - name: google.cloud
    version: ">=1.0.0"
  - name: community.general
    version: ">=6.0.0"
  - name: dataiku.dss
    source: https://github.com/dataiku/dataiku-ansible-collection
    type: git
    version: main

```

## Handlers

The role defines the following handlers:

- `restart dataiku` - Restarts the Dataiku DSS service
- `restart nginx` - Restarts the Nginx service

## Tasks

The role executes the following tasks in order:

### 1. Install Dependencies (`tasks/install_dependencies.yml`)

- Updates apt cache
- Installs Let's Encrypt dependencies (if enabled)
- Installs Java JDK
- Installs Python and development tools
- Installs pip packages
- Adds Docker GPG key and repository
- Installs Docker Engine and related packages (docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin)
- Removes Google Cloud CLI snap package
- Adds Google Cloud apt repository
- Installs gcloud CLI and google-cloud-cli-gke-gcloud-auth-plugin
- Downloads and installs kubectl
- Creates required directories

### 2. Create Dataiku User and Group (`tasks/create_user.yml`)

- Creates Dataiku system group (name: `{{ dataiku_group }}`, default: dataiku)
- Creates Dataiku system user with:
  - User name: `{{ dataiku_user }}` (default: dataiku)
  - Group: `{{ dataiku_group }}`
  - Home directory: `{{ dataiku_data_dir }}` (default: /data/dataiku)
  - Shell: /bin/bash
  - System user (system: yes)
  - Home directory creation enabled (create_home: yes)
- Sets ownership on Dataiku directories (recursive):
  - `{{ dataiku_install_dir }}`
  - `{{ dataiku_data_dir }}`

### 3. Download and Install Dataiku (`tasks/install_dataiku.yml`)

- Checks if Dataiku is already installed (by checking if installation directory exists)
- Downloads Dataiku DSS tarball
- Extracts Dataiku archive
- Sets permissions on installation directory
- Checks if data directory is initialized
- Installs Dataiku dependencies via install-deps.sh (with LibreOffice, R, and Chrome support)
- Initializes Dataiku data directory with installer.sh
- Installs R integration via dssadmin
- Installs license file if provided
- Adds Dataiku user to docker and sudo groups

### 4. Configure Dataiku Instance (`tasks/configure_dataiku.yml`)

- Downloads Hadoop standalone libraries
- Checks if Hadoop archive exists
- Downloads Spark standalone libraries
- Checks if Spark archive exists
- Installs Hadoop integration via dssadmin
- Installs Spark integration via dssadmin
- Removes default Nginx vhost (if dns_name is set)
- Configures custom Nginx vhost from template (if dns_name is set)
- Registers Let's Encrypt certificate (if enabled)
- Installs graphics export functionality (PDF and images)
- Sets nofile and nproc limits for Dataiku user (65535)
- Builds Docker base image for container execution
- Builds Docker base image for code environment execution (CDE)
- Builds Docker Spark image
- Configures gcloud Docker registry authentication for GCP region
- Enables user namespaces (sets user.max_user_namespaces to 128344)
- Downloads and installs GCP monitoring agent (if enabled)

### 5. Setup Systemd Service (`tasks/setup_service.yml`)

- Runs install-boot.sh script to create systemd service unit file
  - Script location: `{{ dataiku_install_dir }}/dataiku-dss-{{ dataiku_version }}/scripts/install/install-boot.sh`
  - Arguments: data directory path and dataiku user name
- Reloads systemd daemon to recognize new service
- Enables Dataiku service to start on boot
- Starts Dataiku service immediately

## Templates

### nginx_dss.jinja2

Nginx reverse proxy configuration for Dataiku DSS web interface. This template creates a reverse proxy that:

- Listens on port 80
- Uses the configured `dns_name` as server_name
- Proxies requests to Dataiku DSS on port `{{ dataiku_port }}`
- Supports WebSocket connections (required for Dataiku UI)
- Configures appropriate timeouts (read: 3600s, send: 600s)
- Disables client body size limits for large file uploads
- Sets proper headers for X-Forwarded-For and Host

## Example Playbook

### Basic Installation

```yaml
---
- hosts: dataiku_servers
  become: yes
  roles:
    - role: dataiku
```

### Custom Installation with Variables

```yaml
---
- hosts: dataiku_servers
  become: yes
  roles:
    - role: dataiku
      vars:
        dataiku_version: "14.2.0"
        dataiku_port: 10000
        dataiku_install_dir: "/opt/dataiku"
        dataiku_data_dir: "/data/dataiku"
        java_package: "openjdk-11-jdk"
```

### Installation with SSL/TLS

```yaml
---
- hosts: dataiku_servers
  become: yes
  roles:
    - role: dataiku
      vars:
        dns_name: "dataiku.example.com"
        use_letsencrypt: true
        letsencrypt_email: "admin@example.com"
        dataiku_version: "14.2.0"
```

### Installation with License File

```yaml
---
- hosts: dataiku_servers
  become: yes
  roles:
    - role: dataiku
      vars:
        dataiku_license_file: "/path/to/license.json"
        dataiku_version: "14.2.0"
```

### Installation with GCP Monitoring

```yaml
---
- hosts: dataiku_servers
  become: yes
  roles:
    - role: dataiku
      vars:
        dataiku_version: "14.2.0"
        use_gcp_monitoring: true
        gcp_region: "us-central1"
```

## Post-Installation

After running this role, Dataiku DSS will be:

1. Installed at `{{ dataiku_install_dir }}/dataiku-dss-{{ dataiku_version }}/`
2. Running as a systemd service named `dataiku`
3. Accessible on port `{{ dataiku_port }}` (default: 10000)
4. Running as user `{{ dataiku_user }}` (default: dataiku)
5. Configured with Docker integration
6. Configured with Spark and Hadoop integration (if archives were successfully downloaded)
7. Configured with R integration, LibreOffice, and Chrome support
8. Configured with GCP tools (gcloud CLI, kubectl, GKE auth plugin)
9. Configured with graphics export functionality (PDF and images)
10. Configured with Docker base images (container-exec, CDE, and Spark)
11. Configured with gcloud Docker registry authentication
12. Configured with user namespaces enabled
13. Optionally configured with GCP monitoring agent (if enabled)

### Access Dataiku DSS

- Without Nginx: `http://<server-ip>:10000`
- With Nginx: `http://<dns_name>` or `https://<dns_name>` (if Let's Encrypt is enabled)


### Service Management

```bash
# Start Dataiku
sudo systemctl start dataiku

# Stop Dataiku
sudo systemctl stop dataiku

# Restart Dataiku
sudo systemctl restart dataiku

# Check status
sudo systemctl status dataiku

# View logs
sudo journalctl -u dataiku -f
```

### Dataiku CLI

As the dataiku user, you can use the dssadmin CLI:

```bash
sudo su - dataiku
cd /data/dataiku
./bin/dssadmin --help
```


## Troubleshooting

### Common Issues

1. **Port already in use**: Ensure port 10000 (or your custom port) is not being used by another service
2. **Docker permission denied**: Ensure the dataiku user is in the docker group (role handles this automatically)
3. **Let's Encrypt fails**: Ensure DNS is properly configured and pointing to the server before running the playbook
4. **Installation check**: The role checks if Dataiku is already installed by looking for the installation directory path
5. **Google Cloud CLI snap conflicts**: The role automatically removes the snap version before installing the apt version
6. **Docker image build failures**: Ensure sufficient disk space and memory for building base images (container-exec, CDE, Spark)
7. **GCP Docker registry authentication**: Ensure gcloud is properly authenticated before Docker registry configuration
8. **User namespace errors**: The role automatically enables user namespaces by setting user.max_user_namespaces to 128344
9. **GCP monitoring agent**: Only installed when use_gcp_monitoring is set to true

### Logs Location

- Dataiku logs: `/data/dataiku/run/backend.log`
- Nginx logs: `/var/log/nginx/access.log` and `/var/log/nginx/error.log`
- Systemd logs: `journalctl -u dataiku`

## Version Compatibility

This role has been tested with:

- Dataiku DSS 14.2.0
- Ubuntu 22.04
- Ansible 2.9+
