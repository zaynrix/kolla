# GitHub Actions Workflow Setup

Since your Personal Access Token doesn't have the `workflow` scope, please add the workflow file manually through GitHub UI:

## Steps:

1. **Go to your repository:** https://github.com/zaynrix/kolla

2. **Create the workflow file:**
   - Click "Add file" → "Create new file"
   - Path: `.github/workflows/deploy.yml`
   - Copy and paste the content from the file below

3. **Commit the file:**
   - Click "Commit new file"
   - The workflow will be created

4. **Enable GitHub Pages:**
   - Go to: https://github.com/zaynrix/kolla/settings/pages
   - Under "Source", select **"GitHub Actions"**
   - Click "Save"

5. **Verify:**
   - Go to: https://github.com/zaynrix/kolla/actions
   - You should see the workflow running

---

## Workflow File Content:

Copy this entire content into `.github/workflows/deploy.yml`:

```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Build web
        run: flutter build web --release --base-href "/kolla/"

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

---

## Alternative: Update Your Token

If you want to push via command line, update your Personal Access Token:

1. Go to: https://github.com/settings/tokens
2. Create a new token or edit existing one
3. Check the **`workflow`** scope
4. Update your git credentials with the new token

