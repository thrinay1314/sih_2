
# KisanLink Frontend

The frontend single-page web app for KisanLink, offering direct farmgate-to-buyer market matching, price discovery, crop listing management, and real-time deal negotiation.

---

## 🚀 Quick Start (Local Development)

### Option 1: Serve standalone using Node
```bash
cd frontend
npm start
```
This serves the frontend at `http://localhost:5000`.

### Option 2: Run full-stack from the Backend
```bash
cd ../backend
npm start
```
The backend automatically detects and serves the `frontend/` folder at `http://localhost:3000`.

---

## 🌐 Connecting to your Deployed Backend

Before or after deploying the frontend, configure the backend API target:

1. **Option A: Edit `config.js`**
   Open `config.js` and set `window.API_BASE`:
   ```javascript
   window.API_BASE = 'https://your-kisanlink-backend.onrender.com';
   ```

2. **Option B: Dynamic Runtime Setting in Browser**
   You or demo judges can also point the frontend to any live backend endpoint directly from the browser DevTools Console:
   ```javascript
   localStorage.setItem('KISANLINK_API_BASE', 'https://your-backend.url');
   location.reload();
   ```

3. **Option C: Same-Domain / Reverse Proxy**
   Leave `window.API_BASE = ''`. All calls will go to `/api/...` relative to the current host.

---

## 📦 Deployment Guides

### Deploy to Vercel (Recommended)
1. Push your code to GitHub.
2. Go to [vercel.com](https://vercel.com) and click **Add New Project**.
3. Import your repository and set the **Root Directory** to `frontend`.
4. Leave build settings default (`Output Directory`: leave empty/current).
5. Click **Deploy**. Vercel uses `vercel.json` automatically!

### Deploy to Netlify
1. Go to [netlify.com](https://netlify.com) and import your Git repository.
2. Set **Base directory** to `frontend`.
3. Leave **Build command** empty and **Publish directory** as `frontend` (or `.`).
4. Click **Deploy Site**. Netlify will use `netlify.toml` / `_redirects` automatically!

### Deploy to Render (Static Site)
1. Go to [render.com](https://render.com) > **New** > **Static Site**.
2. Connect your Git repository.
3. Set **Root Directory** to `frontend`.
4. Set **Publish directory** to `.`.
5. Click **Create Static Site**.

### Deploy to GitHub Pages
1. In repository settings, go to **Pages**.
2. If using GitHub Actions, select the `frontend/` directory as the deployment source.
