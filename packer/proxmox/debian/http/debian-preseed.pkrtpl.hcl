# ================================================================
# File: packer/proxmox/debian/http/debian-preseed.pkrtpl.hcl
# Purpose:
#   Render the Debian preseed file consumed by the Packer HTTP server
#   during unattended template builds.
#
# Notes:
#   - This template is used for both Debian 12 and Debian 13 builds.
#   - The default admin user is retained for the initial Packer SSH
#     connection and for downstream homelab bootstrap workflows.
# ================================================================

d-i debian-installer/locale string ${locale}
d-i keyboard-configuration/xkb-keymap select ${keyboard_layout}
d-i keyboard-configuration/toggle select No toggling
d-i time/zone string ${timezone}
d-i clock-setup/utc boolean true
d-i clock-setup/ntp boolean true

d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string ${hostname}
d-i netcfg/get_domain string local

d-i passwd/root-login boolean false
d-i passwd/make-user boolean true
d-i passwd/user-fullname string ${admin_username}
d-i passwd/username string ${admin_username}
d-i passwd/user-password-crypted password ${admin_password_hash}
d-i user-setup/allow-password-weak boolean true

d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

d-i partman-auto/method string regular
d-i partman-auto/disk string /dev/sda
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

d-i base-installer/install-recommends boolean true

tasksel tasksel/first multiselect standard, ssh-server

d-i pkgsel/include string qemu-guest-agent cloud-init sudo curl wget ca-certificates bash-completion nano openssh-server
d-i pkgsel/upgrade select full-upgrade

d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string /dev/sda
d-i grub-pc/install_devices multiselect /dev/sda
d-i grub-pc/install_devices_empty boolean false

d-i preseed/late_command string \
    in-target mkdir -p /home/${admin_username}/.ssh; \
    in-target /bin/sh -c "printf '%s\n' '${ssh_public_key}' > /home/${admin_username}/.ssh/authorized_keys"; \
    in-target chown -R ${admin_username}:${admin_username} /home/${admin_username}/.ssh; \
    in-target chmod 700 /home/${admin_username}/.ssh; \
    in-target chmod 600 /home/${admin_username}/.ssh/authorized_keys; \
    in-target /bin/sh -c "printf '%s\n' '${admin_username} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-${admin_username}"; \
    in-target chmod 440 /etc/sudoers.d/99-${admin_username}; \
    in-target systemctl enable qemu-guest-agent; \
    in-target systemctl enable ssh

d-i finish-install/reboot_in_progress note
