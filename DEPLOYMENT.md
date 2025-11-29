# GitHub Pages Deployment Guide

## Automatic Deployment (Recommended)

The repository includes a GitHub Actions workflow that automatically builds and deploys your Flutter web app to GitHub Pages whenever you push to the `main` branch.

### Setup Steps:

1. **Enable GitHub Pages:**
   - Go to: https://github.com/zaynrix/kolla/settings/pages
   - Under "Source", select **"GitHub Actions"**
   - Click "Save"

2. **Push the workflow file:**
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Add GitHub Pages deployment"
   git push origin main
   ```

3. **Verify deployment:**
   - Go to: https://github.com/zaynrix/kolla/actions
   - You should see the "Deploy Flutter Web to GitHub Pages" workflow running
   - Once complete, your app will be available at:
     **https://zaynrix.github.io/kolla/**

## Manual Deployment

If you prefer to deploy manually:

1. **Build the web app:**
   ```bash
   flutter build web --release --base-href "/kolla/"
   ```

2. **Push the build folder:**
   - The built files are in `build/web/`
   - You can push this folder to a `gh-pages` branch or use GitHub Pages settings

## Troubleshooting

- If the workflow fails, check the Actions tab for error messages
- Make sure GitHub Pages is enabled in repository settings
- The base URL is set to `/kolla/` - adjust if your repository name is different
- First deployment may take a few minutes

## Custom Domain (Optional)

To use a custom domain:
1. Add a `CNAME` file in the `web/` folder with your domain
2. Configure DNS settings as per GitHub Pages documentation

