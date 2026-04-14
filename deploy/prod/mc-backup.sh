#!/bin/sh

# Fail immediately if credentials are not set
: "${MINIO_ROOT_USER:?MINIO_ROOT_USER is required}"
: "${MINIO_ROOT_PASSWORD:?MINIO_ROOT_PASSWORD is required}"

echo "Waiting for MinIO to be ready..."
until mc alias set myminio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"; do
  echo "MinIO not ready yet, retrying in 10s..."
  sleep 10
done
echo "MinIO alias configured."

# Run backup loop: sleep until 2am each day, then mirror all buckets
while true; do
  # Use expr to strip leading zeros — POSIX sh portable (10# is a bashism, fails in ash)
  h=$(date +%H); h=$(expr "$h" + 0)
  m=$(date +%M); m=$(expr "$m" + 0)
  s=$(date +%S); s=$(expr "$s" + 0)
  secs_since_midnight=$(( h * 3600 + m * 60 + s ))
  target_secs=7200  # 2am = 7200 seconds from midnight

  if [ "$secs_since_midnight" -lt "$target_secs" ]; then
    sleep_secs=$(( target_secs - secs_since_midnight ))
  else
    sleep_secs=$(( 86400 - secs_since_midnight + target_secs ))
  fi

  echo "Next backup scheduled in ${sleep_secs}s (at 2am)"
  sleep "$sleep_secs"

  echo "[$(date)] Starting nightly mirror to /backup..."
  if mc mirror --overwrite --remove myminio/ /backup/; then
    echo "[$(date)] Backup complete."
  else
    echo "[$(date)] ERROR: mc mirror failed" >&2
  fi
done
