# AUTOwn'26 Website — Flutter + Python

**Theme:** *Connecting Industry Innovation with Intelligent Automotive Excellence*
**Main event:** 13–14 February 2027 · **Prize pool:** ₹4,00,000

```
autown26/
├── backend/            Python (FastAPI) – content API + registrations (SQLite)
│   ├── content.py      ← ALL website text lives here (edit this to update the site)
│   ├── main.py         API server; also serves the Flutter build
│   └── requirements.txt
└── frontend/           Flutter web app
    ├── pubspec.yaml
    └── lib/
        ├── main.dart               page shell, nav bar, drawer, scrolling
        ├── api.dart                HTTP calls to the backend
        ├── theme.dart              colours & fonts
        ├── sections/               hero (countdown + animated road), about, tracks,
        │                           events, speakers, schedule, sponsorship, FAQ, contact
        └── widgets/                shared UI + registration dialog
```

## 1. Run the backend
```bash
cd backend
python -m venv .venv && source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```
API docs: http://localhost:8000/docs

## 2. Run the Flutter frontend (development)
Requires the Flutter SDK (3.19+).
```bash
cd frontend
flutter create . --platforms web      # one-time: generates the web/ folder
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
```

## 3. Production (one server)
```bash
cd frontend && flutter build web --release
cd ../backend && uvicorn main:app --host 0.0.0.0 --port 8000
```
The backend automatically serves `frontend/build/web` at `/`, so the site and API share one origin
(no `API_URL` needed).

## Admin: view / export registrations
Set a secret first: `export AUTOWN_ADMIN_KEY=your-secret` (default is `change-me` — change it!).
```bash
curl -H "X-Admin-Key: your-secret" http://localhost:8000/api/registrations
curl -H "X-Admin-Key: your-secret" http://localhost:8000/api/registrations.csv -o registrations.csv
```

## Updating content
Everything (speakers, schedule, fees, FAQs, sponsorship tiers, venue, support email) is in
`backend/content.py`. Items marked **TBA** are placeholders — replace them once confirmed.
Restart the backend and refresh the page; no Flutter rebuild needed.

| Env var | Default | Purpose |
|---|---|---|
| `AUTOWN_ADMIN_KEY` | `change-me` | protects registration export |
| `AUTOWN_DB` | `backend/autown26.db` | SQLite file path |
| `AUTOWN_CORS` | `*` | allowed origins (comma-separated) |
