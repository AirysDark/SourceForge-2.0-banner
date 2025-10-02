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
