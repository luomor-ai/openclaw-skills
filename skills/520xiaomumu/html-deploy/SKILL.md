---
name: html-deploy
description: Deploy HTML content or files to the web via htmlcode.fun. Use when the user asks to "deploy to web", "host this html", "generate a live link for this frontend", or provides HTML code that needs an online preview. Support for single-file HTML deployment with instant URL generation.
---

# HTML Deploy

This skill provides a streamlined workflow to take any HTML code or local HTML file and deploy it to a public URL using the `htmlcode.fun` service.

## Workflow

1.  **Extract/Generate HTML**: Identify the HTML content to be deployed.
2.  **Call Deployment Script**: Use the bundled PowerShell script to handle the JSON payload and API call.

### Using the Deployment Script

Run the following command in the terminal:

```powershell
pwsh ./scripts/deploy.ps1 -Content '<your_html_content>' -Filename 'your_filename.html'
```

*Note: For complex HTML with many quotes, it is safer to write the JSON payload to a temporary file first and use curl directly as shown in the script's implementation.*

### Manual Deployment (Preferred for AI)

To avoid shell escaping issues with large HTML strings:

1.  Write the deployment payload to a temporary JSON file:
    ```json
    {
      "filename": "index.html",
      "content": "<!DOCTYPE html>..."
    }
    ```
2.  Execute the deployment via `curl`:
    ```bash
    curl -s -X POST https://www.htmlcode.fun/api/deploy -H "Content-Type: application/json" --data-binary "@temp_payload.json"
    ```

## API Response

A successful deployment returns a JSON object:
- `url`: The live public link (e.g., `https://www.htmlcode.fun/s/xxxxxx`)
- `qrCode`: A link to a QR code for mobile access.
- `cooldownSeconds`: Wait time before the next deployment.

## Limits

- Only supports single HTML files.
- Rate limits apply (typically 10 seconds cooldown).
