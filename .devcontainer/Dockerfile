FROM mcr.microsoft.com/devcontainers/base:debian

# Keep image lean: skip docs/manpages/locales during package install.
RUN set -eux; \
    printf 'path-exclude /usr/share/doc/*\npath-exclude /usr/share/man/*\npath-exclude /usr/share/locale/*\npath-include /usr/share/locale/en*\n' > /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        verilator \
        iverilog \
        make \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/*
