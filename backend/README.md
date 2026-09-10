# KisanLink Backend

The Node.js/Express REST API backend for KisanLink. Provides authenticated user registration/login with bcrypt password hashing, JWT sessions, real-time crop inventory management, buyer/farmer search, deal workflows, and admin controls.

---

## 🚀 Quick Start (Local Development)

```bash
cd backend
npm install
npm start
```

The API starts at **http://localhost:3000**.
If the `frontend/` folder exists alongside `backend/`, the server also serves the web application at `http://localhost:3000`.

### Health Check
Verify the server is running by opening:
[http://localhost:3000/api/health](http://localhost:3000/api/health)

---

## 🔐 Environment Variables

Create a `.env` file in the `backend/` directory (or copy from `.env.example`):

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3000` | Port for the Express HTTP server |
| `JWT_SECRET` | *(required in prod)* | Strong random secret key for signing JWT tokens |
| `SESSION_MINUTES` | `60` | Token expiration duration in minutes |

---

## 🌐 Deploying the Backend Separately

### 1. Deploy on Render (Recommended)
1. Push your repository to GitHub.
2. Go to [render.com](https://render.com) > **New** > **Web Service**.
3. Connect your repository.
4. Set:
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
5. Add Environment Variables:
   - `JWT_SECRET`: *(Click Generate or enter a long random string)*
   - `SESSION_MINUTES`: `60`
6. Click **Create Web Service**.
7. Copy your deployed service URL (e.g., `https://kisanlink-backend.onrender.com`).
8. Paste that URL into `frontend/config.js` or configure it in the frontend.

### 2. Deploy on Railway
1. Go to [railway.app](https://railway.app) > **New Project** > **Deploy from GitHub repo**.
2. Set the Root Directory to `/backend` in Service Settings.
3. Add environment variables `JWT_SECRET` and `SESSION_MINUTES`.
4. Deploy!

### 3. Deploy on Fly.io
```bash
cd backend
fly launch
fly deploy
```

---

## 📡 API Overview

| Method | Route | Access | Description |
|---|---|---|---|
| `GET` | `/api/health` | Public | System uptime, timestamp, and database stats |
| `POST` | `/api/register` | Public | Register a new Farmer or Buyer account |
| `POST` | `/api/login` | Public | Authenticate with mobile/password, returns JWT |
| `GET` | `/api/me` | Authenticated | Validate current JWT session and retrieve profile |
| `GET` | `/api/crops` | Public | List crops (optionally filter by `farmerId`) |
| `POST` | `/api/crops` | Farmer | List new crop for sale |
| `PATCH` | `/api/crops/:id/status` | Farmer | Update crop listing status |
| `DELETE` | `/api/crops/:id` | Farmer | Remove crop listing |
| `GET` | `/api/buyers/search` | Public | Search verified buyers and APMC mandis |
| `GET` | `/api/farmers/search` | Public | Search available farmers and produce |
| `POST` | `/api/deals` | Farmer/Buyer | Initiate a new deal |
| `GET` | `/api/deals/history` | Authenticated | Retrieve user transaction history |
| `PATCH` | `/api/deals/:id/advance`| Authenticated | Advance deal through milestone stages |
| `GET` | `/api/admin/stats` | Admin | High-level platform metrics |
| `GET` | `/api/admin/users` | Admin | List all registered farmers and buyers |
| `DELETE` | `/api/admin/users/:id` | Admin | Delete a user from the platform |
| `GET` | `/api/admin/history` | Admin | View platform-wide transaction history |
| `GET` | `/api/listings` | Admin | Moderation queue for buyer listings |
| `POST` | `/api/listings/:id/approve` | Admin | Verify a buyer listing |
| `POST` | `/api/listings/:id/remove` | Admin | Remove a listing |
