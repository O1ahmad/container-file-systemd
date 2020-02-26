# specific OS distribution to utilize as base image
ARG OS_VERSION=centos:7

FROM $OS_VERSION

# Create directory for storage of additional entrypoint scripts
RUN mkdir /entrypoint.d
COPY entrypoints/01-systemd-units.sh /entrypoint.d

# Include custom cmd/entrypoint for rendering and activating custom units
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
