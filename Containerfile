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

# 1. Ensure ImageMagick and fonts are present for the build phase
RUN dnf install -y ImageMagick liberation-sans-fonts

# 2. Create the hicolor icons directory path if it doesn't exist
RUN mkdir -p /usr/share/icons/hicolor/256x256/apps/

# 3. Generate the "WORD PROCESSOR" text icon
RUN convert -size 256x256 xc:transparent \
            -font Liberation-Sans-Bold \
            -gravity center \
            -fill "rgba(40, 40, 40, 0.8)" -draw "roundrectangle 10,40 246,216 25,25" \
            -fill "#FFFFFF" -pointsize 32 -interline-spacing -2 -draw "text 0,0 'WORD\nPROCESSOR'" \
            /usr/share/icons/hicolor/256x256/apps/kiosk-writer.png

# 4. Generate the "INTERNET BROWSER" text icon
RUN convert -size 256x256 xc:transparent \
            -font Liberation-Sans-Bold \
            -gravity center \
            -fill "rgba(40, 40, 40, 0.8)" -draw "roundrectangle 10,40 246,216 25,25" \
            -fill "#FFFFFF" -pointsize 32 -interline-spacing -2 -draw "text 0,0 'INTERNET\nBROWSER'" \
            /usr/share/icons/hicolor/256x256/apps/kiosk-browser.png

# 5. Point the respective desktop launchers to your custom text icons
RUN sed -i 's/^Icon=.*/Icon=kiosk-writer/' /usr/share/applications/libreoffice-writer.desktop
RUN sed -i 's/^Icon=.*/Icon=kiosk-browser/' /usr/share/applications/org.mozilla.firefox.desktop

# Make libexec scripts executable
RUN chmod 755 /usr/libexec/*.sh

# Enable systemd (root) services
RUN systemctl enable sikker-reset-bruger-home.service

# Enable user services 
RUN systemctl --global enable usb-monitor.service
RUN systemctl --global enable kiosk-monitor.service

# Create the bootc kargs directory and write the parameters out to a TOML file
# for a quieter boot experience and to hide systemd status messages
RUN mkdir -p /usr/lib/bootc/kargs.d && \
    echo 'kargs = ["quiet", "splash", "loglevel=3", "rd.systemd.show_status=false", "systemd.show_status=false"]' \
    > /usr/lib/bootc/kargs.d/10-quiet-boot.toml

# Update dconf database with new configurations
RUN dconf update

# Ship schema files for runtime consumers.
COPY --from=ctx /system_files/usr/share/sikker-selvbetjening/schemas /usr/share/sikker-selvbetjening/schemas

    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
