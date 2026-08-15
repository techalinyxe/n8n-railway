# n8n — Self-Hosted sur Railway

Instance n8n 2.25.7, Dockerfile custom (Node 22 bullseye-slim), connectée à Supabase PostgreSQL, déployée sur Railway.

## Déploiement

1. New Project → Deploy from GitHub repo sur Railway
2. Ajoute les variables de .env.example dans Settings → Variables
3. Settings → Volumes → Add Volume, mount path /home/nodejs/.n8n
4. Settings → Networking → Generate Domain
5. Reporte le domaine dans N8N_EDITOR_BASE_URL et WEBHOOK_URL, redeploy
