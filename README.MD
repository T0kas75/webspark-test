# Nginx + PHP-FPM Infra Homework (Terraform + Ansible)

Minimal PHP application infrastructure using:
- Terraform (Docker provider) to deploy containers
- Ansible role to install and configure Nginx + PHP-FPM on host
- GitHub Actions CI for Terraform and Ansible linting



## Prerequisites

### Terraform part (Docker containers)
- Docker Desktop or Docker Engine (local)
- Terraform (tested with 1.4.x)
- curl (or browser)

### Ansible part (host configuration)
- Ansible + ansible-lint
- Linux host (local WSL Ubuntu is OK) with sudo access

Notes for Windows:
- Recommended to run Terraform and Ansible from Ubuntu (WSL2) to avoid Windows path / permissions issues.
- Docker Desktop should be configured with WSL2 backend and integration enabled for your Ubuntu distro.



## Terraform: deploy containers (nginx + php-fpm)

Terraform deploys:
- `nginx` container exposed on host port `8080`
- `php-fpm` container
- shared Docker network and shared `/var/www/html` volume
- `/healthz` endpoint returning JSON:
  `{"status":"ok","service":"nginx","env":"<APP_ENV>"}`

### Run in bash
cd terraform
terraform fmt -recursive
terraform init
terraform validate

terraform apply var="project_name=your_profect_name"

### Validate

curl http://localhost:8080/healthz
### {"status":"ok","service":"nginx","env":"dev"}

curl http://localhost:8080/
### HTML page: "It works on Terraform" + APP_ENV value

### Destroy
terraform destroy -var="project_name=webspark" 



## Ansible: role roles/web (host Nginx + PHP-FPM)

Ansible role installs and configures:
Nginx + PHP-FPM
templates: nginx.conf + index.php
logrotate for /var/log/nginx/*.log
handlers for restarts
idempotent behavior

This implementation runs host-based stack on port 8081 to avoid conflict with Terraform (8080)

### Run (local host / WSL)
from repository root:
ansible-lint -p ansible/site.yml ansible/roles/web

### Apply role:
cd ansible
ansible-playbook -i inventory.ini site.yml --ask-become-pass

### Validate
curl http://localhost:8081/healthz
# {"status":"ok","service":"nginx","env":"dev"}

curl http://localhost:8081/
# HTML page: "It works on Ansible" + APP_ENV value



## CI/CD (GitHub Actions)
Two workflows are provided:

- .github/workflows/terraform.yml
- terraform fmt -check
- terraform init
- terraform validate
- terraform plan -out=tfplan
- uploads tfplan as an artifact

.github/workflows/ansible.yml
- installs ansible + ansible-lint
- runs ansible-lint for ansible/site.yml and ansible/roles/web

### Verify CI runs
Open GitHub repository → Actions tab:

- Terraform workflow should be green and upload tfplan artifact
- Ansible workflow should be green (ansible-lint)

Links to successful runs:

- Terraform workflow run: [<PASTE_LINK_HERE>](https://github.com/T0kas75/webspark-test/actions/runs/20664203901/job/59332984804)
- Ansible workflow run: [<PASTE_LINK_HERE>](https://github.com/T0kas75/webspark-test/actions/runs/20664470084/job/59333789630)

