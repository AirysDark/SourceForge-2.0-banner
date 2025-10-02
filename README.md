# SF2 Full Scrub + Plugin Banner
- All DietPi branding fully swapped to SourceForge 2.0 (SF2).
- Paths redirected to /usr/lib/sf2, /etc/sf2, /var/lib/sf2, /run/sf2.
- New **plugin banner system**: /usr/lib/sf2/banner.d/*.sh modules.
- Master launcher: /usr/local/bin/sf2-banner
  
uninstall
```Bash
curl -fsSL https://raw.githubusercontent.com/AirysDark/SourceForge-2.0-banner/main/uninstall-sf2.sh | sudo bash
```
install
```bash
curl -fsSL https://raw.githubusercontent.com/AirysDark/SourceForge-2.0-banner/main/install-sf2-complete.sh | sudo bash
```
```bash
ls -l /etc/update-motd.d/00-sf2-banner
ls -l /etc/profile.d/00-sf2-banner.sh
sudo chmod +x /etc/update-motd.d/00-sf2-banner
sudo chmod +x /etc/profile.d/00-sf2-banner.sh
```
```bash
ls -l /etc/update-motd.d/00-sf2-banner
ls -l /etc/profile.d/00-sf2-banner.sh
sudo chmod +x /etc/update-motd.d/00-sf2-banner
sudo chmod +x /etc/profile.d/00-sf2-banner.sh
```
```bash
sudo chmod -x /etc/update-motd.d/*
sudo chmod +x /etc/update-motd.d/00-sf2-banner
```
```bash
sudo tee /etc/update-motd.d/99-sf2-banner >/dev/null <<'EOF'
#!/bin/sh
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
EOF
sudo chmod +x /etc/update-motd.d/99-sf2-banner
```
```bash
#!/bin/sh
# Run SF2 banner before DietPi MOTD
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner

# --- DietPi MOTD content (unchanged) ---
# Example:
echo "DietPi v$G_DIETPI_VERSION ..."
# (etc, DietPi MOTD stuff goes here)

# Run SF2 banner after DietPi MOTD
[ -x /usr/local/bin/sf2-banner ] && /usr/local/bin/sf2-banner
```
```bash
sudo tee /usr/local/bin/sf2-live >/dev/null <<'SH'
#!/usr/bin/env bash
exec watch -t -n 5 /usr/local/bin/sf2-banner
SH
sudo chmod +x /usr/local/bin/sf2-live

# Run it
sf2-live   # Ctrl-C to exit
```
```bash
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<'INI'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin dietpi --noclear %I $TERM
Type=idle
INI
sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.service
```
```bash
tee -a ~/.bash_profile >/dev/null <<'SH'
# Auto-start SF2 live dashboard on local console only
if [[ -t 1 && "$(tty 2>/dev/null)" == "/dev/tty1" && -x /usr/local/bin/sf2-live ]]; then
  exec /usr/local/bin/sf2-live
fi
SH
```
```bash
sudo rm /etc/systemd/system/getty@tty1.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.service
```
