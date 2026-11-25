# AUTOwn'26 Website (Flutter, no backend)

**Theme:** *Connecting Industry Innovation with Intelligent Automotive Excellence*
**Main event:** 13–14 February 2027 · **Pre-event workshops:** 12 February 2027 · **Prize money up to ₹4,00,000**

The site is a static Flutter web app. Registrations happen on **Zoho Backstage**; there is no
backend server or database.

```
Dockerfile               builds the Flutter site and serves it with nginx (used by Render)
nginx.conf.template      web server settings
frontend/
├── assets/content.json  ← ALL website text + Zoho Backstage links (edit this)
├── assets/images/       logos and the 46-years badge
└── lib/
    ├── main.dart                 page shell, navigation
    ├── content.dart              loads content.json
    ├── theme.dart                brochure colours and fonts
    ├── sections/                 hero, about, tracks, events, schedule, contact…
    └── widgets/register_dialog.dart   Competitions / Workshop / Attendee → Zoho Backstage
```

## Run locally
```powershell
cd frontend
flutter pub get
flutter run -d web-server --web-port 5000
```
Open http://localhost:5000. (Or `flutter run -d chrome`.)

## Connect Zoho Backstage registration
1. In Zoho Backstage, create a ticket class for each option you want people to register for
   (e.g. each competition, each workshop, presentations, attendee types). Use the same names as the
   website so people can find them easily.
2. Copy your event's registration link (the event website's Register/Tickets link, or the link that the
   **Register Ticket** embeddable widget opens).
3. Open `frontend/assets/content.json` and find the `"registration"` block:
   - Paste the link into `"zoho_event_url"`. Every option uses this link by default.
   - If you have a separate link for a particular ticket, paste it into that option's `"zoho_url"`.
4. Push to GitHub; Render redeploys automatically.

Until a link is added, the Register button shows "Online registration will open soon".

## Edit content
Everything (text, tracks, events, fees, schedule, coordinators, FAQ, registration options) is in
`frontend/assets/content.json`. Keep it valid JSON: double quotes, commas between items, no trailing commas.

## Deploy (Render)
The Render web service uses the `Dockerfile` (runtime: **Docker**). No environment variables are needed.
