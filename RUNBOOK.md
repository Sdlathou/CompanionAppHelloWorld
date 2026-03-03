# RUNBOOK — Hello World full-stack app

This runbook documents the minimal additions made to the repository to prove
**frontend ↔ backend communication** works on a fresh Ubuntu 24.04 VM provisioned
via the existing Slices-based infrastructure.

---

## What was added (and why)

| File | Why added |
|---|---|
| `app/backend/server.py` | Python 3 HTTP server (stdlib only — no pip installs). Serves `GET /api/hello` as JSON and also serves the static frontend from the same origin on port 8080. |
| `app/frontend/index.html` | Single-page HTML that calls `/api/hello` via `fetch()` and renders the response. Keeping it in one file avoids build tooling. |
| `deploy-app.sh` | Shell script to be piped to the VM over SSH after `setup-server.sh` has provisioned the machine. Clones the repo, installs a systemd service, and opens port 8080. Hooks into the existing provision flow without modifying the existing scripts. |

Nothing in the existing scripts (`create-experiment.sh`, `setup-server.sh`,
`install-and-setup-slices.sh`) was changed.

---

## End-to-end deployment flow

```
[local machine — Python venv with Slices CLI]
  1.  source install-and-setup-slices.sh     # one-time: install CLI + auth
  2.  source create-experiment.sh            # create & share experiment
  3.  bash   setup-server.sh                 # provision Ubuntu 24.04 VM, wait until ready
                                             # → prints SSH login command
  4.  ssh ubuntu@<VM_IP> 'bash -s' < deploy-app.sh   # deploy the app on the VM
```

After step 4 succeeds:

- **Frontend** → `http://<VM_IP>:8080/`
- **API**      → `http://<VM_IP>:8080/api/hello`

---

## Verifying the deployment

```bash
# Check service status
ssh ubuntu@<VM_IP> 'systemctl status helloworld'

# Hit the API directly
curl http://<VM_IP>:8080/api/hello
# Expected: {"message": "Hello from backend", "ts": "2024-...Z"}
```

Open `http://<VM_IP>:8080/` in a browser to see the frontend fetch and display
the backend response.

---

## Redeploying after a code change

Re-running `deploy-app.sh` on the VM performs a `git pull` and restarts the
systemd service automatically:

```bash
ssh ubuntu@<VM_IP> 'bash -s' < deploy-app.sh
```
