#!/usr/bin/env bash
# Generates 600px-wide JPEG thumbnails for every photo in photo-keys.txt
# and uploads them to s3://kcdtexas-photos-prod/public/thumbs/<filename>.
#
# Requirements: aws CLI (configured), ffmpeg
# Run from the repo root: ./generate-thumbs.sh

set -euo pipefail

BUCKET="kcdtexas-photos-prod"
ENDPOINT="https://us-east-1.linodeobjects.com"
THUMB_WIDTH=600
# ffmpeg q:v: 1-31, lower = better quality. 3 ≈ 85% JPEG quality.
QUALITY=3

KEYS_FILE="photo-keys.txt"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mapfile -t KEYS < <(tr '\t' '\n' < "$KEYS_FILE" | grep '^public/KCD')

total=${#KEYS[@]}
ok=0
fail=0

echo "Generating $total thumbnails → s3://$BUCKET/public/thumbs/"
echo ""

for key in "${KEYS[@]}"; do
  filename=$(basename "$key")
  orig="$TMPDIR/$filename"
  thumb="$TMPDIR/thumb_$filename"
  n=$((ok + fail + 1))

  printf "[%3d/%d] %s ... " "$n" "$total" "$filename"

  if aws s3 cp "s3://$BUCKET/$key" "$orig" \
        --endpoint-url "$ENDPOINT" --quiet \
     && ffmpeg -i "$orig" -vf "scale=${THUMB_WIDTH}:-2" -q:v "$QUALITY" \
              "$thumb" -y -loglevel error \
     && aws s3 cp "$thumb" "s3://$BUCKET/public/thumbs/$filename" \
              --endpoint-url "$ENDPOINT" \
              --acl public-read \
              --content-type "image/jpeg" \
              --quiet; then
    ok=$((ok + 1))
    echo "ok"
  else
    fail=$((fail + 1))
    echo "FAILED"
  fi

  rm -f "$orig" "$thumb"
done

echo ""
echo "Done: $ok succeeded, $fail failed"
