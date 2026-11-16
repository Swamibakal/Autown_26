"""
All AUTOwn'26 site content lives here.
Edit this file to update the website — the Flutter frontend reads it via /api/site.
Items marked "TBA" are placeholders until details are confirmed.
"""

EVENT = {
    "name": "AUTOwn'26",
    "theme": "Connecting Industry Innovation with Intelligent Automotive Excellence",
    "tagline": "Project & Paper Presentations • Competitions • Technical Workshops",
    "start_date": "2027-02-13T09:30:00+05:30",
    "end_date": "2027-02-14T17:00:00+05:30",
    "date_label": "13–14 February 2027",
    "venue_short": "BITS Pilani, Hyderabad Campus",
    "prize_pool": "₹4,00,000",
    "registration_notice": "Competition registrations are open. Last date will be announced soon.",
    "organiser": "BITS Pilani – Work Integrated Learning Programmes (WILP)",
    "support_email": "",  # TODO: add the official support email (hidden on the site while empty)
}

VISION = {
    "text": (
        "AUTOwn'26 bridges the gap between industry innovation and academic excellence in "
        "the automotive domain. It brings together researchers, working professionals, students, "
        "industry leaders and policymakers to explore how intelligent systems — autonomy, AI, "
        "connectivity, cybersecurity and electrification — are shaping the next generation of mobility."
    ),
    "objectives": [
        {"icon": "hub", "title": "Connect Industry & Academia",
         "text": "Create a shared platform where industry challenges meet academic research and fresh ideas."},
        {"icon": "psychology", "title": "Intelligent Mobility",
         "text": "Explore AI, autonomy, connectivity and security in software-defined vehicles."},
        {"icon": "build", "title": "Hands-on Excellence",
         "text": "Learn by doing through technical workshops, live competitions and project showcases."},
    ],
}

TRACKS = [
    {"icon": "directions_car", "title": "Autonomous Vehicles",
     "text": "Perception, planning, control and ADAS for self-driving systems."},
    {"icon": "smart_toy", "title": "AI & Machine Learning",
     "text": "Data-driven decision making, vision and predictive intelligence for vehicles."},
    {"icon": "security", "title": "Automotive Cybersecurity",
     "text": "Securing connected vehicles, ECUs, V2X and OTA updates."},
    {"icon": "ev_station", "title": "Electric & Hybrid Vehicles",
     "text": "Batteries, BMS, power electronics, charging and sustainable mobility."},
    {"icon": "memory", "title": "Software-Defined Vehicles",
     "text": "Embedded software, AUTOSAR, vehicle architectures and digital twins."},
    {"icon": "precision_manufacturing", "title": "Automotive & Allied Domains",
     "text": "Manufacturing, Industry 4.0, materials and supply-chain innovation."},
]

EVENTS = [
    {
        "id": "paper",
        "category": "Presentation",
        "icon": "article",
        "title": "Paper Presentation",
        "text": "Present original research or review papers on any AUTOwn'26 track before a panel of academic and industry experts.",
        "fee": "TBA",
        "team": "1–3 members",
        "open": True,
    },
    {
        "id": "project",
        "category": "Presentation",
        "icon": "co_present",
        "title": "Project & Poster Presentation",
        "text": "Showcase working prototypes, simulations or posters solving real automotive problems.",
        "fee": "TBA",
        "team": "1–4 members",
        "open": True,
    },
    {
        "id": "minicar",
        "category": "Competition",
        "icon": "sports_motorsports",
        "title": "Autonomous Mini Car Racing",
        "text": "Program a scaled autonomous car to complete the track fastest without human intervention.",
        "fee": "TBA (per team)",
        "team": "2–4 members",
        "open": True,
    },
    {
        "id": "drone",
        "category": "Competition",
        "icon": "flight",
        "title": "Autonomous Drone Racing",
        "text": "Navigate an autonomous drone through gates using onboard perception and planning. Teams must clear a simulation round.",
        "fee": "TBA (per team)",
        "team": "2–4 members",
        "open": True,
    },
    {
        "id": "workshop-cyber",
        "category": "Workshop",
        "icon": "shield",
        "title": "Automotive Cybersecurity Workshop",
        "text": "Hands-on session on CAN bus attacks, intrusion detection and secure vehicle architectures.",
        "fee": "Free for registered attendees",
        "team": "Individual",
        "open": True,
    },
    {
        "id": "workshop-sdv",
        "category": "Workshop",
        "icon": "developer_board",
        "title": "Software-Defined Vehicles Workshop",
        "text": "From ECUs to centralised compute — build and test a simple vehicle function end-to-end.",
        "fee": "Free for registered attendees",
        "team": "Individual",
        "open": True,
    },
    {
        "id": "attendee",
        "category": "Attendee",
        "icon": "badge",
        "title": "Attendee Registration",
        "text": "Attend keynotes, talks, exhibitions and workshops as an audience member.",
        "fee": "Free",
        "team": "Individual",
        "open": True,
    },
]

SPEAKERS = [
    # Replace with confirmed speakers. "photo" can be a URL; leave empty to show initials.
    {"name": "Speaker to be announced", "role": "Industry Keynote", "org": "Automotive OEM", "photo": "", "link": ""},
    {"name": "Speaker to be announced", "role": "Research Keynote", "org": "Academic Institute", "photo": "", "link": ""},
    {"name": "Speaker to be announced", "role": "Technology Talk", "org": "Tier-1 Supplier", "photo": "", "link": ""},
    {"name": "Speaker to be announced", "role": "Panel Expert", "org": "Mobility Start-up", "photo": "", "link": ""},
]

SCHEDULE = [
    {
        "day": "Day 1",
        "date": "13 Feb 2027",
        "items": [
            {"time": "09:30 – 10:00", "title": "Inauguration", "type": "ceremony"},
            {"time": "10:00 – 13:00", "title": "Keynotes & Invited Talks", "type": "talk"},
            {"time": "13:00 – 14:00", "title": "Lunch", "type": "break"},
            {"time": "14:00 – 16:00", "title": "Automotive Cybersecurity Workshop", "type": "workshop"},
            {"time": "16:00 – 16:20", "title": "Tea Break", "type": "break"},
            {"time": "16:20 – 18:00", "title": "Paper & Project Presentations", "type": "presentation"},
        ],
    },
    {
        "day": "Day 2",
        "date": "14 Feb 2027",
        "items": [
            {"time": "09:30 – 10:30", "title": "Industry & Sponsor Sessions", "type": "talk"},
            {"time": "10:30 – 10:45", "title": "Tea Break", "type": "break"},
            {"time": "10:45 – 13:00", "title": "Competitions: Mini Car Race • Drone Race", "type": "competition"},
            {"time": "13:00 – 14:00", "title": "Lunch", "type": "break"},
            {"time": "14:00 – 16:00", "title": "Software-Defined Vehicles Workshop", "type": "workshop"},
            {"time": "16:15 – 17:00", "title": "Valedictory & Prize Distribution", "type": "ceremony"},
        ],
    },
]

SPONSORSHIP = {
    "tagline": "Put your brand in front of the future of smart mobility.",
    "tiers": [
        {"name": "Bronze", "price": "₹75,000", "color": "#CD7F32",
         "perks": ["Logo on website", "Mention in brochure"]},
        {"name": "Silver", "price": "₹1,00,000", "color": "#C0C0C0",
         "perks": ["All Bronze perks", "Stall space", "Social media shout-out"]},
        {"name": "Gold", "price": "₹2,00,000", "color": "#FFC94D",
         "perks": ["All Silver perks", "Speaking slot", "Logo on banners"]},
        {"name": "Platinum", "price": "₹3,00,000", "color": "#9FE7FF",
         "perks": ["All Gold perks", "Title branding", "Keynote slot", "Prize sponsorship"]},
    ],
}

COORDINATORS = [
    {"name": "Prof. Rakesh Chandra Dash", "role": "Overall Coordinator"},
    {"name": "Prof. Niranjan Raj", "role": "Overall Coordinator"},
]

VENUE = {
    "name": "BITS Pilani, Hyderabad Campus",
    "address": "Jawahar Nagar, Kapra Mandal, Medchal District, Hyderabad, Telangana 500078",
    "map_url": "https://maps.google.com/?q=BITS+Pilani+Hyderabad+Campus",
}

FAQS = [
    {"q": "Who can participate?",
     "a": "Students, WILP learners, working professionals, researchers and start-ups are all welcome."},
    {"q": "Is the registration fee per person or per team?",
     "a": "Competition fees are per team. Attendee registration is individual."},
    {"q": "Will accommodation be provided?",
     "a": "Limited accommodation is available for competition participants on a first-come, first-served basis."},
    {"q": "Do I need my own drone or car for the races?",
     "a": "Hardware details will be shared with registered teams. Drone teams must clear a simulation round first."},
]


def site_payload() -> dict:
    return {
        "event": EVENT,
        "vision": VISION,
        "tracks": TRACKS,
        "events": EVENTS,
        "speakers": SPEAKERS,
        "schedule": SCHEDULE,
        "sponsorship": SPONSORSHIP,
        "coordinators": COORDINATORS,
        "venue": VENUE,
        "faqs": FAQS,
    }
