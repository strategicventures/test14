# RMS AI Services – GL OCR Pipeline

This repository contains an **end-to-end OCR pipeline** for processing **Guarantee Letters (GLs)** used by rehabilitation centres (e.g. PERKESO GLs).

The system automatically:
1. Fetches GL emails and downloads attachments
2. Performs OCR on PDFs/images
3. Extracts structured medical and administrative data
4. Saves results as JSON
5. Inserts / updates records in PostgreSQL

The design is **modular**, **path-safe**, and **production-ready**.

---

##  High-Level Architecture

Email Inbox
   ↓
gl_email_listener.py
   ↓ (PDFs / Images)
app/core/ocr/input/
   ↓
ocr.py
   ↓ (JSON)
app/core/ocr/output/
   ↓
gl_ocr_extract_db_loading.py
   ↓
PostgreSQL (gl_ocr_json table)

---

Processed files are automatically archived to prevent re-processing.

---

## 📁 Folder Structure (Relevant Parts)

app/
├── main.py                          # FastAPI entrypoint
│
├── core/
│   ├── email/
│   │   ├── gl_email_listener.py     # Fetches GL emails & attachments
│   │   └── log/                     # Email processing logs (gitignored)
│   │
│   ├── ocr/
│   │   ├── paths.py                 # Centralised, repo-safe paths
│   │   ├── ocr.py                   # OCR + field extraction logic
│   │   ├── gl_ocr_extract_db_loading.py
│   │   │                             # Loads extracted JSON into PostgreSQL
│   │   ├── input/                   # Incoming PDFs/images (gitignored)
│   │   ├── output/                  # Extracted JSON files (gitignored)
│   │   ├── archive/                 # Processed PDFs/images (gitignored)
│   │   ├── log/                     # OCR logs (gitignored)
│   │   └── postgres_logs/           # Database loader logs (gitignored)
│   │
│   └── schemas/
│       └── gl_schema.py             # Structured GL field definitions


Patient data folders are **intentionally excluded from Git** via `.gitignore`.

---

## Requirements

### Python
- Python **3.11+** recommended

### Python Dependencies
Installed via:

        pip install -r requirements.txt

--- 

## System Dependencies (Required)
These cannot be installed via pip.
### macOS
        brew install tesseract
        brew install poppler

### Ubuntu / Debian
        sudo apt-get install tesseract-ocr poppler-utils

### Windows
        Install Tesseract OCR and add it to PATH
        Install Poppler for Windows

---

## Environment Variables
## No credentials are hardcoded.
## Set the following before running.
 ##     Email (IMAP)

        export RMS_IMAP_SERVER="mail.example.com"
        export RMS_IMAP_EMAIL="user@example.com"
        export RMS_IMAP_PASSWORD="password"
        export RMS_IMAP_PORT="993"
        export RMS_IMAP_MAILBOX="inbox"
        export RMS_AUTORUN_OCR="1"

##      Database (PostgreSQL)

        export RMS_DB_HOST="localhost"
        export RMS_DB_PORT="5432"
        export RMS_DB_NAME="rms"
        export RMS_DB_USER="rms_user"
        export RMS_DB_PASSWORD="your_db_password"

---

## How to Run (One Command)
Full Pipeline (Email → OCR → DB)
        python -m app.core.email.gl_email_listener

## This will:
Download GL attachments from email
Save them into app/core/ocr/input/
Run OCR automatically
Generate JSON in output/
Archive processed PDFs
Insert / update records in PostgreSQL


## Output locations:

| Artifact             | Location                      |
| -------------------- | ----------------------------- |
| Raw GL PDFs / images | `app/core/ocr/input/`         |
| Extracted JSON files | `app/core/ocr/output/`        |
| Archived PDFs        | `app/core/ocr/archive/`       |
| Email logs           | `app/core/email/log/`         |
| OCR logs             | `app/core/ocr/log/`           |
| DB loader logs       | `app/core/ocr/postgres_logs/` |

---

##  Design Principles
No hardcoded file paths
No credentials in code
Each script has a single responsibility
Safe to run on any machine
Won’t reprocess the same GL

---

## Support
If something fails:
Check logs in the relevant log/ folder