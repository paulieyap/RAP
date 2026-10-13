# RAP: self-contained GPU environment (mirrors scripts/install.sh)
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Ubuntu 22.04 ships Python 3.10, matching the prebuilt wheels in install.sh (cp310)
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-dev python-is-python3 \
        git wget unzip ca-certificates build-essential \
        libgl1 libglib2.0-0 libgomp1 libusb-1.0-0 libsm6 libxext6 libxrender1 libegl1 \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --upgrade pip

# Reuse the repo's own install script so the environment stays identical
WORKDIR /opt/rap-install
COPY scripts/install.sh requirements_other.txt ./
RUN bash install.sh

# Writable HOME/caches for whatever UID the container runs as
ENV HOME=/tmp/home \
    HF_HOME=/tmp/home/.cache/huggingface \
    MPLCONFIGDIR=/tmp/home/.cache/matplotlib \
    GRADIO_SERVER_NAME=0.0.0.0
RUN mkdir -p /tmp/home && chmod 1777 /tmp/home

COPY docker/entrypoint.sh /usr/local/bin/rap-entrypoint
RUN chmod +x /usr/local/bin/rap-entrypoint

# The repo is bind-mounted here at runtime (see docker-compose.yml)
WORKDIR /workspace
EXPOSE 7860
ENTRYPOINT ["rap-entrypoint"]
CMD ["python", "app.py"]
