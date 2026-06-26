# Anemone GRUB theme

The Anemone GRUB theme is installed at
`/boot/grub/themes/anemone/theme.txt` in the live image. The live-build GRUB
override at `config/bootloaders/grub-pc/theme.cfg` selects it. Despite the
directory name, live-build uses the `grub-pc` templates to generate the GRUB
configuration used by the EFI image as well.

## Real GRUB UI and background art

GRUB renders the title, subtitle, boot menu entries, selected-entry colour,
keyboard help and timeout progress bar. These remain editable text and are not
flattened into the background.

The current background art is the existing `/boot/grub/splash.png`. It is a
temporary 3084 x 2313 (4:3) image shared with live-build's fallback theme. Any
text already present in that image is background art and cannot react to menu
state or localization.

## GRUB limitations

- GRUB themes support a small set of widgets and are not HTML/CSS layouts.
- A filled or rounded selected-row highlight requires pixmap assets. Until
  those exist, selection is indicated by a restrained colour change.
- Font rendering is limited to fonts compiled into GRUB's PF2 format. This
  theme uses the Unicode font already loaded by live-build.
- Firmware chooses the available graphics mode. The layout uses percentages,
  but very low resolutions and unusual aspect ratios can still affect spacing.
- BIOS uses ISOLINUX in the current build configuration, so it receives the
  matching menu title and labels but not the GRUB visual theme.

## Assets and replacement

The preferred replacement background is a PNG in a 4:3 aspect ratio. Supply at
least 800 x 600 pixels; 1600 x 1200 is the recommended working size. Keep the
important artwork clear of the upper-centre title, the left/middle-left menu,
and the bottom help area. PNG should be non-interlaced and use RGB or RGBA
colour supported by GRUB's PNG module.

To replace the temporary background later:

1. Add the reviewed asset under
   `config/includes.binary/boot/grub/themes/anemone/` without changing source
   concept images.
2. Change `desktop-image` in `theme.txt` to the new filename.
3. Keep `/boot/grub/splash.png` only while the old live-build theme is required
   as a fallback; remove it in a separate, tested cleanup.

## Testing checklist

- Build an ISO only in the normal build/test workflow; this change itself does
  not require committing generated build output.
- Boot the ISO in UEFI mode at 800 x 600, 1024 x 768 and one widescreen mode.
- Confirm the Anemone background, title, subtitle and footer are visible.
- Confirm the primary entry reads
  `Anemone OS – Utforska utan att lämna några spår`.
- Confirm no installer entry is displayed.
- Confirm arrow-key selection is clear and Enter boots the live system.
- Confirm the timeout indicator renders and the default entry boots.
- Confirm the fail-safe, integrity-check and UEFI firmware entries work where
  applicable.
- Boot in legacy BIOS mode and confirm the ISOLINUX title is
  `Anemone OS Live` and its live entries use the Anemone labels.
- Inspect `/boot/grub/grub.cfg` and `/boot/grub/theme.cfg` in the built image for
  unresolved `@...@` placeholders.
