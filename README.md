# KMUTTSTS Storage Service

This repository manages the MinIO storage service for the KMUTTSTS project using Docker Compose.

## 1. Repository Setup

1. Initialize git and push to GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: MinIO storage setup"
   git branch -M main
   # Create a new repository on GitHub named 'KMUTTSTS-Storage'
   git remote add origin https://github.com/yourusername/KMUTTSTS-Storage.git
   git push -u origin main
   ```

## 2. Infrastructure Setup (On the new VM)

1. **Install Docker & Docker Compose**:
   Ensure Docker is installed and running on your storage VM.

2. **Install GitHub Runner**:

   - Go to your repository on GitHub -> Settings -> Actions -> Runners -> New self-hosted runner.
   - Follow the instructions to install and start the runner on your VM.
   - Ensure the runner is tagged as `self-hosted`.

3. **Configure GitHub Secrets**:
   Go to Settings -> Secrets and variables -> Actions -> New repository secret.
   Add the following secrets:
   - `MINIO_ROOT_USER`: Your desired admin username.
   - `MINIO_ROOT_PASSWORD`: Your desired admin password (strong password).

## 3. Deployment

The GitHub Action workflow (`.github/workflows/deploy.yml`) is configured to deploy automatically on push to `main`.

- It uses the self-hosted runner on your VM.
- It pulls the latest MinIO image.
- It starts the service using the secrets you configured.

## 4. Updating the Backend

Once MinIO is running on the new VM, you need to update the **KMUTTSTS-Backend** configuration to point to it.

1. Open `KMUTTSTS-Backend/.env`.
2. Update the following variables:

   ```env
   # The public IP or Domain of your new Storage VM
   MINIO_ENDPOINT=your.storage.vm.ip

   # Ensure these match your new setup
   MINIO_PORT=9000
   MINIO_USE_SSL=false # Set to true if you set up Nginx/Certbot later

   # Update credentials if you changed them
   MINIO_ACCESS_KEY=your-root-user-from-secrets
   MINIO_SECRET_KEY=your-root-password-from-secrets

   # Important for video streaming:
   # Should look like: http://your.storage.vm.ip:9000/kmuttsts
   HLS_BASE_URL=http://your.storage.vm.ip:9000/kmuttsts
   ```

## 5. Verification

1. Access the MinIO Console at `http://your.storage.vm.ip:9001`.
2. Login with your credentials.
3. Ensure your buckets are created (you may need to migrate data or create buckets manually if not persisting volume from old setup).
