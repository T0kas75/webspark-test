# Decisions

## Variables and defaults
- **project_name** is required to make all Docker resources (containers/network/volume) uniquely named and avoid collisions between runs.
- **host_port (default 8080)** matches the task requirement and keeps validation simple (`curl http://localhost:8080/...`).
- **app_env (default dev)** is injected into both `index.php` and `/healthz` response to prove configuration is parameterized and environment-aware.

## Nginx ↔ PHP-FPM connection (socket vs TCP)
- **Ansible (host-based): Unix socket**  was chosen because it is the default local communication method on a single host (no extra listening port, simpler firewall/security).
- **Terraform (Docker-based): FastCGI via service name** (Nginx `fastcgi_pass` points to the PHP-FPM container on the shared Docker network). This avoids host networking and keeps traffic internal to Docker networking.

## Idempotency in Ansible
- Used idempotent modules (`apt`, `template`, `file`, `service`) instead of raw shell commands.
- Templates trigger handlers only on change (`notify` → `Restart Nginx` / `Restart PHP-FPM`), so services restart only when configuration content changes.
- Validation commands (e.g. `nginx -t`) are marked with `changed_when: false` to avoid false-positive “changed” state.

## /healthz implementation
- `/healthz` is served directly by Nginx using a static JSON response and `application/json` content type.
- It confirms:
  - Nginx is up and routing correctly
  - the configured environment value (`env`) is injected properly
- The root endpoint `/` serves `index.php` to confirm PHP handling is working end-to-end.

## What I would improve with more time
- Add **Molecule** tests for the Ansible role (including idempotency test) in CI.
- Optionally build custom Docker images for Nginx/PHP with configs baked in (more “immutable” and production-like).
