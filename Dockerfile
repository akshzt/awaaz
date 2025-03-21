# Use an NVIDIA CUDA base image with Python 3
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04

ENV PYTHON_VERSION=3.11

# Set the working directory in the container
WORKDIR /usr/src/app

# Avoid interactive prompts from apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install any needed packages
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install \
                   ffmpeg \
                   libsndfile1 \
                   python3-pip \
                   python${PYTHON_VERSION} \
                   libcudnn9-cuda-12 \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements.txt file
COPY requirements.txt requirements.txt

# Install any needed packages specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy SSL Cert
COPY /certs/nginx-selfsigned.crt /certs/nginx-selfsigned.crt
COPY /certs/nginx-selfsigned.key /certs/nginx-selfsigned.key

# Copy the rest of your application's code
COPY . .

# Make port 8765 available to the world outside this container
EXPOSE 8765

# Define environment variable
ENV NAME=VoiceStreamAI
ENV CERT_FILE=/certs/nginx-selfsigned.crt
ENV KEY_FILE=/certs/nginx-selfsigned.key

# Set the entrypoint to your application
COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
