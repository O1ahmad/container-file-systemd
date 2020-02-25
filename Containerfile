FROM centos:7 as unit_config

RUN sudo mkdir /entrypoint.d

COPY entrypoints/01-systemd-units.sh /entrypoint.d

COPY entrypoint /entrypoint
RUN sudo chmod +x /entrypoint

ENTRYPOINT ["/entrypoint"]
