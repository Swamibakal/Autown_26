"""
AUTOwn'26 backend (FastAPI)

Run:
    pip install -r requirements.txt
    uvicorn main:app --reload --port 8000

Endpoints:
    GET  /api/health
    GET  /api/site                 -> all page content (from content.py)
    POST /api/register             -> save a registration
    GET  /api/registrations        -> list registrations   (needs X-Admin-Key header)
    GET  /api/registrations.csv    -> export as CSV        (needs X-Admin-Key header)
    POST /api/contact              -> save a contact/enquiry message

If the Flutter web build exists at ../frontend/build/web it is served at "/".
"""
import csv
import io
import os
import sqlite3
from contextlib import closing
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, EmailStr, Field, field_validator

from content import EVENTS, site_payload

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = Path(os.getenv("AUTOWN_DB", BASE_DIR / "autown26.db"))
ADMIN_KEY = os.getenv("AUTOWN_ADMIN_KEY", "change-me")
WEB_BUILD = BASE_DIR.parent / "frontend" / "build" / "web"
VALID_EVENT_IDS = {e["id"] for e in EVENTS}

app = FastAPI(title="AUTOwn'26 API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("AUTOWN_CORS", "*").split(","),
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------- database ----------
def db() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db() -> None:
    with closing(db()) as conn, conn:
        conn.execute(
            """CREATE TABLE IF NOT EXISTS registrations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                event_id TEXT NOT NULL,
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                phone TEXT NOT NULL,
                organisation TEXT,
                team_name TEXT,
                team_size INTEGER,
                message TEXT,
                created_at TEXT NOT NULL,
                UNIQUE(event_id, email)
            )"""
        )
        conn.execute(
            """CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                message TEXT NOT NULL,
                created_at TEXT NOT NULL
            )"""
        )


init_db()


# ---------- models ----------
class Registration(BaseModel):
    event_id: str
    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    phone: str = Field(min_length=7, max_length=20)
    organisation: Optional[str] = Field(default=None, max_length=150)
    team_name: Optional[str] = Field(default=None, max_length=100)
    team_size: Optional[int] = Field(default=None, ge=1, le=10)
    message: Optional[str] = Field(default=None, max_length=1000)

    @field_validator("event_id")
    @classmethod
    def check_event(cls, v: str) -> str:
        if v not in VALID_EVENT_IDS:
            raise ValueError("Unknown event")
        return v

    @field_validator("phone")
    @classmethod
    def check_phone(cls, v: str) -> str:
        digits = "".join(ch for ch in v if ch.isdigit())
        if len(digits) < 7:
            raise ValueError("Enter a valid phone number")
        return v.strip()


class Contact(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    message: str = Field(min_length=5, max_length=2000)


def now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def require_admin(key: Optional[str]) -> None:
    if key != ADMIN_KEY:
        raise HTTPException(status_code=401, detail="Invalid admin key")


# ---------- routes ----------
@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/site")
def site():
    return site_payload()


@app.post("/api/register", status_code=201)
def register(reg: Registration):
    try:
        with closing(db()) as conn, conn:
            cur = conn.execute(
                """INSERT INTO registrations
                   (event_id, name, email, phone, organisation, team_name, team_size, message, created_at)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                (reg.event_id, reg.name.strip(), reg.email.lower(), reg.phone, reg.organisation,
                 reg.team_name, reg.team_size, reg.message, now()),
            )
            reg_id = cur.lastrowid
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=409, detail="This email is already registered for this event.")
    return {"id": reg_id, "ticket": f"AUT26-{reg_id:05d}",
            "message": "Registration successful! Further details will be emailed to you."}


@app.post("/api/contact", status_code=201)
def contact(c: Contact):
    with closing(db()) as conn, conn:
        conn.execute(
            "INSERT INTO contacts (name, email, message, created_at) VALUES (?, ?, ?, ?)",
            (c.name.strip(), c.email.lower(), c.message, now()),
        )
    return {"message": "Thanks! The AUTOwn'26 team will get back to you."}


@app.get("/api/registrations")
def list_registrations(x_admin_key: Optional[str] = Header(default=None)):
    require_admin(x_admin_key)
    with closing(db()) as conn:
        rows = conn.execute("SELECT * FROM registrations ORDER BY id DESC").fetchall()
    return [dict(r) for r in rows]


@app.get("/api/registrations.csv")
def export_registrations(x_admin_key: Optional[str] = Header(default=None)):
    require_admin(x_admin_key)
    with closing(db()) as conn:
        cur = conn.execute("SELECT * FROM registrations ORDER BY id")
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
    buf = io.StringIO()
    w = csv.writer(buf)
    w.writerow(cols)
    w.writerows([tuple(r) for r in rows])
    buf.seek(0)
    return StreamingResponse(iter([buf.getvalue()]), media_type="text/csv",
                             headers={"Content-Disposition": "attachment; filename=autown26_registrations.csv"})


# ---------- serve Flutter web build (if built) ----------
if WEB_BUILD.exists():
    app.mount("/assets", StaticFiles(directory=WEB_BUILD / "assets"), name="assets")

    @app.get("/{path:path}", include_in_schema=False)
    def spa(path: str):
        file = (WEB_BUILD / path).resolve()
        if path and file.is_file() and WEB_BUILD.resolve() in file.parents:
            return FileResponse(file)
        return FileResponse(WEB_BUILD / "index.html")
