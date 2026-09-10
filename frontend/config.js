/**
 * KisanLink Frontend Configuration
 *
 * When deploying the frontend and backend to separate hosting providers
 * (e.g., Frontend on Vercel/Netlify/GitHub Pages and Backend on Render/Railway/Fly.io):
 *
 * Set `API_BASE` below to your deployed backend URL (without trailing slash).
 * Example:
 *   window.API_BASE = 'https://kisanlink-backend.onrender.com';
 *
 * If left empty (''), the frontend sends relative requests to '/api/...',
 * which works automatically when:
 * 1. Running locally with full-stack backend (`npm start` in backend).
 * 2. Serving both frontend and API from the same domain or reverse proxy.
 *
 * You can also set/override this at runtime in the browser DevTools Console:
 *   localStorage.setItem('KISANLINK_API_BASE', 'https://your-backend.url');
 * To reset:
 *   localStorage.removeItem('KISANLINK_API_BASE');
 */
window.API_BASE = 'https://sih-2-850l.onrender.com';
