Project: Anemone Linux
Base: Debian Trixie (testing)
Tool: live-build

sudo lb clean --purge

sudo lb config \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free non-free-firmware" \
  --debian-installer live \
  --bootappend-live "boot=live components quiet splash systemd.show_status=false"

sudo lb build 2>&1 | tee build.log

Custom:
- Plymouth theme (anemone)
- GNOME wallpaper
- /etc/os-release branding


sudo lb config \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free non-free-firmware" \
  --debian-installer live \
  --bootappend-live "boot=live components quiet splash systemd.show_status=false"
