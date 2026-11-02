const http = require('http');
const { Pool } = require('pg');

// ADR 0003: self-hosted replacement for the Supabase ranking backend.
// Same contract as before — anonymous insert of a score, anonymous read of
// the top N per mode. No auth, no identity: matches the risk already
// accepted in ADR 0001 (RLS only allowed insert+select; here the DB role
// `sprachheld_api` enforces the same boundary natively).

const ALLOWED_ORIGIN = process.env.ALLOWED_ORIGIN || 'https://sprachheld.jesusaraujo.lat';
const MODES = ['arcade', 'verbs', 'gender', 'clock'];
const MAX_NAME_LEN = 24;
const MAX_MODE_LEN = 32;
const PORT = process.env.PORT || 3000;

const pool = new Pool({
  host: process.env.PGHOST,
  port: Number(process.env.PGPORT || 5432),
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  max: 5,
});

function withCors(res) {
  res.setHeader('Access-Control-Allow-Origin', ALLOWED_ORIGIN);
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

function sendJson(res, status, body) {
  withCors(res);
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 10_000) req.destroy();
    });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

function isValidScorePayload(body) {
  if (typeof body.mode !== 'string' || !MODES.includes(body.mode)) return false;
  if (body.name != null && (typeof body.name !== 'string' || body.name.length > MAX_NAME_LEN)) return false;
  const correct = body.correct ?? 0;
  const total = body.total ?? 0;
  if (!Number.isInteger(correct) || !Number.isInteger(total)) return false;
  if (correct < 0 || total < 0 || correct > total) return false;
  if (body.score != null && (!Number.isInteger(body.score) || body.score < 0)) return false;
  if (body.best_combo != null && !Number.isInteger(body.best_combo)) return false;
  if (body.duration_seconds != null && !Number.isInteger(body.duration_seconds)) return false;
  return true;
}

async function handleSubmit(req, res) {
  const raw = await readBody(req);
  let body;
  try {
    body = JSON.parse(raw);
  } catch {
    return sendJson(res, 400, { error: 'invalid json' });
  }
  if (!isValidScorePayload(body)) return sendJson(res, 400, { error: 'invalid payload' });

  const name = body.name?.trim() || null;
  await pool.query(
    `INSERT INTO sprachheld.scores (name, mode, correct, total, best_combo, score, duration_seconds)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [name, body.mode, body.correct ?? 0, body.total ?? 0, body.best_combo ?? null, body.score ?? null, body.duration_seconds ?? null]
  );
  sendJson(res, 201, { ok: true });
}

async function handleTop(req, res, url) {
  const mode = url.searchParams.get('mode');
  if (!mode || !MODES.includes(mode) || mode.length > MAX_MODE_LEN) {
    return sendJson(res, 400, { error: 'invalid mode' });
  }
  const limit = Math.min(Number(url.searchParams.get('limit')) || 20, 100);

  const { rows } = await pool.query(
    `SELECT name, mode, correct, total, best_combo, score, created_at
     FROM sprachheld.scores
     WHERE mode = $1
     ORDER BY score DESC NULLS LAST, created_at DESC
     LIMIT $2`,
    [mode, limit]
  );
  sendJson(res, 200, rows);
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    withCors(res);
    res.writeHead(204);
    return res.end();
  }
  const url = new URL(req.url, `http://${req.headers.host}`);
  try {
    if (req.method === 'POST' && url.pathname === '/scores') return await handleSubmit(req, res);
    if (req.method === 'GET' && url.pathname === '/scores') return await handleTop(req, res, url);
    if (req.method === 'GET' && url.pathname === '/health') return sendJson(res, 200, { ok: true });
    sendJson(res, 404, { error: 'not found' });
  } catch (err) {
    console.error(err);
    sendJson(res, 500, { error: 'internal error' });
  }
});

server.listen(PORT, () => console.log(`sprachheld-ranking-api listening on ${PORT}`));
