# use an official light-weight Python runtime as base image
FROM python:3.11-slim

# sets the working directory
WORKDIR /app


ARG APP_VERSION=dev
ARG WEATHER_API_KEY

# sets environment variables for security & performance
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_VERSION=${APP_VERSION} \
    WEATHER_API_KEY=${WEATHER_API_KEY}

# install systemdependencies
RUN sed -i 's|http://deb.debian.org|https://deb.debian.org|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# copy the dependencies file to the working directory
COPY requirements.txt .

# install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# copy the application code to the working directory
COPY app.py . 

# create a non-root user for security
RUN useradd -m -r appuser && chown appuser:appuser /app

# switch to the non-root user
USER appuser 

# expose port 5000
EXPOSE 5000

# command to run the application
CMD ["python", "app.py"]


