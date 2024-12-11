# Simple Docker-based read-only AiiDA webserver

- .aiida archives are mounted in a volume.
- the container is stateless and for each .aiida file
  - sets up a zip profile;
  - starts restapi in the background.

Run with

```
docker compose up -d

curl localhost:5000/api/v4
curl localhost:5001/api/v4
```

## Further ideas

- For production setup, use `gunicorn`
- If any of the background rest-api processes exit/crash, the container won't fix them. Something like `supervisor` could help.
- Should check how much time the rest-api container setup takes for many large files (10GB+).
- The .aiida files should be saved in a persistent volume, and obtained from Object Store or Archive with a separate `downloader` container, which could also handle migrations. This separate container could either be running continuously (to automatically add any new RESTAPIs) or just once at the starts (and could also be triggered manually, e.g. via `docker compose run downloader`).
