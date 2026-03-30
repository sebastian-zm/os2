FROM registry.redhat.io/rhel10/rhel-bootc

LABEL containers.bootc="1" \
    ostree.bootable="1"

COPY usr/ /usr/

RUN dnf group install --with-optional -y \
    "Workstation" \
    "Smart Card Support" \
    "Internet Applications" \
    "TeX formatting system" \
    "Graphical Administration Tools" \
    "RPM Development Tools" \
    "Hardware Monitoring Utilities" \
    "Java Platform" \
    "Java Development" \
    "Development Tools" \
    "Additional Development" \
    "Debugging Tools" \
    "Performance Tools" \
    "Container Management" \
    "System Tools" \
    "Networking Tools" \
    "Security Tools"

RUN curl -OfsSL --output-dir /etc/yum.repos.d/ https://pkgs.tailscale.com/stable/rhel/$(rpm -E %rhel)/tailscale.repo && \
    curl -OfsSL --output-dir /etc/yum.repos.d/ https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo && \
    dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm \
    https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

RUN dnf install -y \
    gnome-shell-extension-dash-to-panel \
    podman-docker \
    wl-clipboard \
    nix \
    tailscale \
    ffmpeg \
    intel-media-driver \
    intel-lpmd \
    pandoc \
    gh \
    btop \
    bat \
    command-line-assistant \
    dkms \
    VirtualBox-7.2 && \
    systemctl enable ostree-state-overlay@nix.service && \
    systemctl set-default graphical.target && \
    dnf clean all && \
    for user in avahi dhcpcd libstoragemgmt pesign wsdd; do \
        entry=$(getent passwd "$user"); \
        uid=$(echo "$entry" | cut -d: -f3); \
        gid=$(echo "$entry" | cut -d: -f4); \
        gecos=$(echo "$entry" | cut -d: -f5); \
        home=$(echo "$entry" | cut -d: -f6); \
        shell=$(echo "$entry" | cut -d: -f7); \
        printf 'u %s %s:%s "%s" %s %s\n' "$user" "$uid" "$gid" "$gecos" "$home" "$shell"; \
    done > /usr/lib/sysusers.d/legacy-rpm-users.conf && \
    for group in power vboxusers; do \
        gid=$(getent group "$group" | cut -d: -f3); \
        printf 'g %s %s\n' "$group" "$gid"; \
    done >> /usr/lib/sysusers.d/legacy-rpm-users.conf && \
    bootc container lint --no-truncate

STOPSIGNAL SIGRTMIN+3

CMD ["/sbin/init"]
