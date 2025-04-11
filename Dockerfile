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
#RUN apk add --no-cache build-base

# copy the dependencies file to the working directory
COPY requirements.txt .

# install python dependencies
RUN pip install --upgrade pip --timeout=10 --retries=2
RUN pip install --no-cache-dir --timeout=10 --retries=2 -r requirements.txt

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


