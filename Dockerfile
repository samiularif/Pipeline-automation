# use an official light-weight Python runtime as base image
FROM python:3.12-slim-bookworm

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
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# copy the dependencies file to the working directory
COPY requirements.txt .

# Use a virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# install python dependencies
RUN pip install --upgrade pip --timeout=100 --retries=5
RUN pip install --no-cache-dir --timeout=100 --retries=5 \
    -i https://pypi.org/simple/ \
    -r requirements.txt
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


