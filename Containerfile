FROM centos:7 as unit_config

RUN mkdir /entrypoint.d
COPY entrypoints/01-systemd-units.sh /entrypoint.d

COPY entrypoint /entrypoint
RUN chmod +x /entrypoint

ENTRYPOINT ["/sbin/init"]
