FROM centos:8 as unit_config

# Create directory for storage of additional entrypoint scripts
RUN mkdir /entrypoint.d
COPY entrypoints/01-systemd-units.sh /entrypoint.d

# Include custom cmd/entrypoint for rendering and activating custom units
COPY entrypoint /entrypoint
RUN chmod +x /entrypoint

ENTRYPOINT ["/sbin/init"]
