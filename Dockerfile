FROM python:3 

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# System packages needed for:
# - pdf2image (poppler-utils)
# - tesseract OCR (eng + msa)
# - opencv runtime libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-msa \
    poppler-utils \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps first for better caching
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the repo
COPY . /app

EXPOSE 8000

# FastAPI entrypoint: app/main.py -> app instance
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
