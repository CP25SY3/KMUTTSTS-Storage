#!/bin/sh
# Wait for MinIO to be reachable before setting up alias
echo "Waiting for MinIO to be ready..."
until mc alias set myminio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" 2>/dev/null; do
  echo "MinIO not ready yet, retrying in 10s..."
  sleep 10
done
echo "MinIO alias configured."

# Run backup loop: sleep until 2am each day, then mirror all buckets
while true; do
  # Seconds since midnight
  current_h=$(date +%H)
  current_m=$(date +%M)
  current_s=$(date +%S)
  secs_since_midnight=$(( (10#$current_h * 3600) + (10#$current_m * 60) + 10#$current_s ))
  target_secs=$((2 * 3600))  # 2am = 7200 seconds from midnight

  if [ "$secs_since_midnight" -lt "$target_secs" ]; then
    sleep_secs=$(( target_secs - secs_since_midnight ))
  else
    sleep_secs=$(( 86400 - secs_since_midnight + target_secs ))
  fi

  echo "Next backup scheduled in ${sleep_secs}s (at 2am)"
  sleep "$sleep_secs"

  echo "[$(date)] Starting nightly mirror to /backup..."
  mc mirror --overwrite --remove myminio/ /backup/
  echo "[$(date)] Backup complete."
done
