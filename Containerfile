# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /system_files

# Base Image
FROM quay.io/fedora-ostree-desktops/silverblue:42

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh

# Copy system files (config, services, scripts) into the image
COPY --from=ctx /system_files/ /

# Make libexec scripts executable
RUN chmod 755 /usr/libexec/*.sh

# Enable systemd (root) services
RUN systemctl enable sikker-reset-bruger-home.service
RUN systemctl enable hide-grub.service

# Enable user services 
RUN systemctl --global enable usb-monitor.service
RUN systemctl --global enable kiosk-monitor.service

# Create the bootc kargs directory and write the parameters out to a TOML file
# for a quieter boot experience and to hide systemd status messages
RUN mkdir -p /usr/lib/bootc/kargs.d && \
    echo 'kargs = ["quiet", "splash", "loglevel=3", "rd.systemd.show_status=false", "systemd.show_status=false"]' \
    > /usr/lib/bootc/kargs.d/10-quiet-boot.toml

# make sure timezone is set to Copenhagen
RUN ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime && \
    echo "Europe/Copenhagen" > /etc/timezone

# Set execution permissions
RUN chmod +x /usr/libexec/power-scheduler.py

# MANUALLY ENABLE THE SERVICE (Bypasses systemd container build bugs)
RUN mkdir -p /etc/systemd/system/multi-user.target.wants/ && \
    ln -s /etc/systemd/system/power-scheduler.service /etc/systemd/system/multi-user.target.wants/power-scheduler.service

# Drop systemd shutdown wait times from 90 seconds to 3 seconds
RUN mkdir -p /etc/systemd/system.conf.d/ && \
    echo -e "[Manager]\nDefaultTimeoutStopSec=3s\nDefaultTimeoutAbortSec=3s" > /etc/systemd/system.conf.d/kiosk-timeout.conf

# Update dconf database with new configurations
RUN dconf update

# Ship schema files for runtime consumers.
COPY --from=ctx /system_files/usr/share/sikker-selvbetjening/schemas /usr/share/sikker-selvbetjening/schemas

    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
