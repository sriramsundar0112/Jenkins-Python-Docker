# Stage :1 Build all the necessary dependencies....

FROM python:3.12-slim AS builder
WORKDIR /dependencies

# Remove the stale package list and update the Package Manager with new list
RUN apt-get update && apt-get install -y --no-install-recommends \
&& rm -rf /var/lib/apt/lists/*

# Copy the requirements.txt to the Stage 1 working director.
COPY requirements.txt ./requirements.txt

# Upgrade the Python pip wheel and install the required dependencies using the requirements.txt
RUN python -m pip install --upgrade pip wheel \
 && pip wheel --wheel-dir /installed_dependencies -r ./requirements.txt

# Stage 2: 
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app

# Install only from dependencies installed in Stage 1 
COPY --from=builder /installed_dependencies /dependencies
RUN pip install --no-cache-dir /dependencies/*

# Copy app code  to the working directory /app folder
COPY app ./app

# Expose port 8000 via docker which can be consumed by port 80 during docker runtime
EXPOSE 8000

# Using CMD command to run the python app when the container starts.
# passing arguments like uvicorn-webserver, host-0.0.0.0 and port 8000
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
