# KisanLink (Smart India Hackathon)

**Direct Farmgate Linkage & APMC e-Marketplace** — Empowering farmers to sell produce directly to verified buyers, institutional procurers, and regional mandis with transparent net-payout calculation, quality grading, and end-to-end deal tracking.

---

## 📁 Repository Structure

The project is cleanly split into separate **`frontend`** and **`backend`** folders to enable seamless, independent deployments:

```
sih/
├── frontend/                     # Single-Page Web Application
│   ├── index.html                # Unified UI with Farmer, Buyer & Admin views
│   ├── config.js                 # API base URL configuration (switch local/prod)
│   ├── package.json              # Local preview scripts
│   ├── vercel.json               # Vercel 1-click deployment configuration
│   ├── netlify.toml              # Netlify SPA routing configuration
│   ├── _redirects                # Netlify SPA rewrite rules
│   └── README.md                 # Frontend deployment guide (Vercel, Netlify, Pages)
│
├── backend/                      # Express REST API & Persistence
│   ├── server.js                 # API server, JWT auth, CORS, route handlers
│   ├── db.js                     # Data access layer
│   ├── data/                     # JSON data storage
│   ├── middleware/
│   │   └── auth.js               # JWT verification & role-based access control
│   ├── package.json              # Backend dependencies & scripts
│   ├── render.yaml               # Render Web Service blueprint
│   ├── .env.example              # Environment variables template
│   └── README.md                 # Backend deployment guide (Render, Railway, Fly.io)
│
├── package.json                  # Root runner script shortcuts
├── .gitignore                    # Monorepo gitignore
├── cloudflared.exe               # Cloudflare Tunnel binary (for live demos)
└── README.md                     # This documentation
```

---

## ⚡ Quick Start (Run Full-Stack Locally)

You can run both frontend and backend together with a single command from the project root:

```bash
# 1. Install backend dependencies (first time only)
npm run install:backend

# 2. Start the application
npm start
```

- Open **http://localhost:3000** in your browser.
- The backend will serve the API at `/api/...` and serve the `frontend/` UI automatically.

---

## 🚀 Easy Deployment

### 1. Deploy the Backend (Render / Railway)
1. In [Render](https://render.com), create a new **Web Service** pointing to this repository.
2. Set **Root Directory** to `backend`.
3. Set **Build Command** to `npm install` and **Start Command** to `npm start`.
4. Add the `JWT_SECRET` environment variable.
5. Copy your deployed backend URL (e.g., `https://kisanlink-api.onrender.com`).

*Detailed backend guide: [backend/README.md](file:///c:/Thrinay/sih/backend/README.md)*

### 2. Deploy the Frontend (Vercel / Netlify)
1. Open `frontend/config.js` and set:
   ```javascript
   window.API_BASE = 'https://kisanlink-api.onrender.com';
   ```
2. In [Vercel](https://vercel.com) or [Netlify](https://netlify.com), import your repository.
3. Set **Root Directory** / **Base directory** to `frontend`.
4. Deploy! Vercel and Netlify will automatically detect `vercel.json` / `netlify.toml`.

*Detailed frontend guide: [frontend/README.md](file:///c:/Thrinay/sih/frontend/README.md)*

---

## 🌐 Live Demo with Cloudflare Tunnel (Alternative)

If presenting a demo directly from your local machine to judges without deploying to cloud servers:

```bash
# 1. Start your local server
npm start

# 2. In another terminal, start the Cloudflare tunnel
./cloudflared.exe tunnel --url http://localhost:3000
```
Cloudflare will give you a public `https://....trycloudflare.com` URL accessible from anywhere on the internet.