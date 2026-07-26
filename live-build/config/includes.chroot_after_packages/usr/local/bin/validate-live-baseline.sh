#!/bin/sh

section()
{
	printf '\n== %s ==\n' "$1"
}

check_package()
{
	package="$1"
	if dpkg-query -W -f='${db:Status-Status} ${Version}\n' "$package" 2>/dev/null | grep -q '^installed '
	then
		printf 'OK: %s installed (' "$package"
		dpkg-query -W -f='${Version}' "$package" 2>/dev/null
		printf ')\n'
	else
		printf 'MISSING: %s is not installed\n' "$package"
	fi
}

check_absent_command()
{
	name="$1"
	command_name="$2"

	if command -v "$command_name" >/dev/null 2>&1
	then
		printf 'UNEXPECTED: %s command found at %s\n' "$name" "$(command -v "$command_name")"
	else
		printf 'OK: %s command absent\n' "$name"
	fi
}

check_absent_package()
{
	package="$1"
	if dpkg-query -W -f='${db:Status-Status}\n' "$package" 2>/dev/null | grep -q '^installed$'
	then
		printf 'UNEXPECTED: %s package installed\n' "$package"
	else
		printf 'OK: %s package absent\n' "$package"
	fi
}

section "/etc/os-release"
cat /etc/os-release 2>/dev/null || printf 'Unable to read /etc/os-release\n'

section "locale"
locale 2>&1

section "timedatectl"
timedatectl 2>&1

section "localectl status"
localectl status 2>&1

section "required desktop packages"
check_package firefox-esr
check_package libreoffice
check_package thunderbird
check_package pipewire
check_package wireplumber

section "developer/cloud tool absence"
check_absent_command dotnet dotnet
check_absent_command aws aws
check_absent_command azure-cli az
check_absent_package dotnet-sdk-8.0
check_absent_package dotnet-sdk-9.0
check_absent_package awscli
check_absent_package azure-cli


# ===== Bas 5 — GRUB/Plymouth/GDM identity (ported from live-template) =====

section "Bas 5 — kernel cmdline (quiet/splash must have survived GRUB→kernel)"
cat /proc/cmdline 2>/dev/null || printf 'Unable to read /proc/cmdline\n'
if grep -q '\bquiet\b' /proc/cmdline 2>/dev/null && grep -q '\bsplash\b' /proc/cmdline 2>/dev/null
then
	printf 'OK: quiet and splash both present on the running kernel cmdline\n'
else
	printf 'UNEXPECTED: quiet/splash missing from the running kernel cmdline\n'
fi

section "Bas 5 — Anemone GRUB theme present on boot medium"
medium=""
for candidate in /run/live/medium /lib/live/mount/medium
do
	if [ -d "$candidate" ]
	then
		medium="$candidate"
		break
	fi
done
if [ -n "$medium" ]
then
	printf 'boot medium: %s\n' "$medium"
	if [ -f "$medium/boot/grub/themes/anemone/theme.txt" ]
	then
		printf 'OK: %s/boot/grub/themes/anemone/theme.txt present\n' "$medium"
	else
		printf 'UNEXPECTED: anemone GRUB theme not found under %s/boot/grub/\n' "$medium"
	fi
	if [ -f "$medium/boot/grub/grub.cfg" ]
	then
		if grep -q '@[A-Z_]*@' "$medium/boot/grub/grub.cfg" 2>/dev/null
		then
			printf 'UNEXPECTED: unresolved @..@ placeholder left in built grub.cfg\n'
		else
			printf 'OK: no unresolved @..@ placeholders in built grub.cfg\n'
		fi
	fi
else
	printf 'Could not find the boot medium mountpoint (checked /run/live/medium,\n'
	printf '/lib/live/mount/medium) — skipping on-disc GRUB file checks.\n'
fi

section "Bas 5 — Anemone Plymouth theme installed and selected as default"
if [ -f /usr/share/plymouth/themes/anemone/anemone.plymouth ]
then
	printf 'OK: /usr/share/plymouth/themes/anemone/anemone.plymouth present\n'
else
	printf 'UNEXPECTED: anemone Plymouth theme files not found under /usr/share/plymouth/themes/\n'
fi
if command -v plymouth-set-default-theme >/dev/null 2>&1
then
	current_theme="$(plymouth-set-default-theme 2>/dev/null || true)"
	printf 'current default Plymouth theme: %s\n' "${current_theme:-unknown}"
	if [ "$current_theme" = "anemone" ]
	then
		printf 'OK: default Plymouth theme is anemone\n'
	else
		printf 'UNEXPECTED: default Plymouth theme is not anemone\n'
	fi
else
	printf 'plymouth-set-default-theme not on PATH — cannot confirm active theme\n'
fi

section "Bas 5 — Anemone theme actually baked into the boot initrd (best effort)"
initrd_image=""
for candidate in /run/live/medium/live/initrd.img /lib/live/mount/medium/live/initrd.img
do
	if [ -f "$candidate" ]
	then
		initrd_image="$candidate"
		break
	fi
done
if [ -z "$initrd_image" ]
then
	printf 'Could not locate live/initrd.img on the boot medium — skipping.\n'
elif ! command -v lsinitramfs >/dev/null 2>&1
then
	printf 'lsinitramfs not available in this session — skipping (not a failure,\n'
	printf 'just cannot introspect the initrd contents from here).\n'
else
	if lsinitramfs "$initrd_image" 2>/dev/null | grep -q 'plymouth/themes/anemone/'
	then
		printf 'OK: anemone theme files found inside %s\n' "$initrd_image"
	else
		printf 'UNEXPECTED: anemone theme files not found inside %s\n' "$initrd_image"
	fi
fi

section "Bas 5 — Anemone branding files present on disk"
for f in /usr/share/backgrounds/anemone/default.jpg \
         /usr/share/gnome-background-properties/anemone.xml \
         /usr/share/anemone/logos/anemone.svg \
         /etc/gdm3/greeter.dconf-defaults
do
	if [ -f "$f" ]
	then
		printf 'OK: %s present\n' "$f"
	else
		printf 'UNEXPECTED: %s missing\n' "$f"
	fi
done

section "Bas 5 — GDM greeter config points at Anemone resources (static file check)"
if grep -q "logo='/usr/share/anemone/logos/anemone.svg'" /etc/gdm3/greeter.dconf-defaults 2>/dev/null
then
	printf 'OK: greeter.dconf-defaults sets the anemone logo\n'
else
	printf 'UNEXPECTED: greeter.dconf-defaults does not reference the anemone logo\n'
fi
if grep -q "picture-uri='file:///usr/share/backgrounds/anemone/default.jpg'" /etc/gdm3/greeter.dconf-defaults 2>/dev/null
then
	printf 'OK: greeter.dconf-defaults sets the anemone background\n'
else
	printf 'UNEXPECTED: greeter.dconf-defaults does not reference the anemone background\n'
fi
printf 'NOTE: this only confirms the config file is correct, not that the\n'
printf 'greeter actually rendered it — GDM regenerates its runtime config via\n'
printf '"generate-config" on every gdm.service start, not verifiable from\n'
printf 'inside an already-running autologin session.\n'

section "Bas 5 — live user desktop session picked up the Anemone background"
if command -v gsettings >/dev/null 2>&1
then
	bg_light="$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null || true)"
	bg_dark="$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null || true)"
	scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)"
	printf 'picture-uri=%s\n' "${bg_light:-unknown}"
	printf 'picture-uri-dark=%s\n' "${bg_dark:-unknown}"
	printf 'color-scheme=%s\n' "${scheme:-unknown}"
	case "$bg_light" in
		*anemone/default.jpg*) printf 'OK: desktop background is the anemone image\n' ;;
		*) printf 'UNEXPECTED: desktop background is not the anemone image\n' ;;
	esac
	case "$scheme" in
		*prefer-dark*) printf 'OK: color-scheme is prefer-dark\n' ;;
		*) printf 'UNEXPECTED: color-scheme is not prefer-dark (configured value did not apply)\n' ;;
	esac
else
	printf 'gsettings not available — re-run from inside the graphical session\n'
fi


section "current user and groups"
id
printf 'USER=%s\n' "${USER:-}"
groups 2>&1
