# KCD Texas Photos

Static photo gallery for KCD Texas events, published at **[photos.kcdtexas.org](https://photos.kcdtexas.org)**.

The site is a single `index.html` page that renders a responsive grid of event photos. Thumbnails are served from Linode Object Storage and the full-size originals load on demand in a lightbox.

## How it works

- **Grid**: 211 thumbnails (600px wide) stored at `s3://kcdtexas-photos-prod/public/thumbs/`
- **Lightbox**: clicking a thumbnail loads the full-size original from `s3://kcdtexas-photos-prod/public/`
- **Hosting**: GitHub Pages (CNAME → photos.kcdtexas.org)

## Adding photos for a new event

1. Upload originals to `s3://kcdtexas-photos-prod/public/` and update `photo-keys.txt` with the new keys
2. Run `./generate-thumbs.sh` to resize and upload thumbnails (requires `aws` CLI and `ffmpeg`)
3. Regenerate the image grid in `index.html` to include the new entries
