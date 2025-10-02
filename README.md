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
sudo bash -c 'set -e; rm -rf /tmp/sf2-src; \
  apt-get update -y >/dev/null 2>&1 || true; apt-get install -y git >/dev/null 2>&1 || true; \
  git clone --depth 1 https://github.com/AirysDark/SourceForge-2.0-banner.git /tmp/sf2-src; \
  cd /tmp/sf2-src; bash install-sf2-complete.sh'
```
