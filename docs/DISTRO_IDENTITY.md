# Anemone Linux Identity

## Position

Anemone Linux is a Debian Stable based workstation for organizations that want
Linux as the primary desktop without abandoning Microsoft-centered operational
workflows.

The target user is not a Linux hobbyist. The target user is an employee,
developer, administrator, analyst, consultant, or public-sector worker who needs
a dependable desktop, Microsoft 365/Azure/.NET compatibility, predictable
updates, and an installation path that does not require Linux knowledge.

## Primary Audience

- Corporate and government organizations evaluating Linux desktop migration.
- Developers working in Azure, .NET, Git, containers, web services, and internal
  enterprise systems.
- IT departments that need a stable, supportable base with familiar tools.
- Windows or macOS users who need a guided, low-friction first Linux experience.

## Product Promise

Anemone should feel like a serious work computer:

- stable by default
- boring in package management
- familiar enough for Windows and macOS users
- ready for Microsoft service portfolios
- clean, not stuffed with unrelated applications
- easy to install, update, enroll, and troubleshoot

## Non-Goals

- Not a gaming distro.
- Not a penetration-testing distro.
- Not an experimental rolling-release desktop.
- Not a general "everything included" live DVD.
- Not a showcase for unstable packages.

## Base System Policy

The base system must track Debian Stable, currently Trixie/Debian 13.

Allowed by default:

- Debian Stable repositories.
- Debian Stable security updates.
- Debian Stable point-release updates.
- Official vendor repositories when required for core Anemone use cases.

Not allowed by default:

- Debian testing.
- Debian unstable/sid.
- Mixed Debian release repositories.
- Repositories with disabled TLS verification.
- APT sources using `trusted=yes`.
- Random PPAs, curl-piped installers, or unsigned package sources.

Exceptions must be documented with:

- the package name
- why it is required
- what repository it comes from
- what version is pinned
- how it is verified
- how it will be retired when official Stable support exists

## Microsoft Compatibility Policy

Microsoft compatibility is part of the distro identity, not optional bloat.
However, it must be implemented in a way that does not weaken the operating
system.

Default Microsoft-facing capabilities should include:

- Azure CLI
- .NET SDK LTS/current supported line selected by release policy
- ASP.NET Core runtime when the SDK does not already cover the use case
- browser access to Microsoft 365 services
- Remote Desktop client support
- SMB/CIFS file sharing support
- certificate, VPN, smart-card, and enterprise authentication foundations where
  practical

Microsoft repositories must use signed package sources and normal TLS
verification. If Azure CLI does not yet publish a package for the current Debian
Stable codename, the fallback must be explicit and pinned, not hidden inside a
global mixed-release setup.

## Package Selection Policy

Anemone should ship a complete work desktop, not every useful package.

Default desktop:

- GNOME core desktop
- Firefox ESR
- basic document/PDF tooling
- network, Bluetooth, audio, printer, scanner, and power management
- terminal and file manager
- update and firmware tooling

Developer/corporate tools:

- Git
- curl/wget
- Python runtime and venv tooling
- Azure CLI
- .NET SDK
- build tools only if the release profile is "developer workstation"

Packages to reconsider for the default image:

- full LibreOffice suite versus a smaller office subset
- Thunderbird versus browser-based Microsoft 365 mail
- VLC versus GNOME media defaults
- AWS CLI unless multi-cloud is part of the product promise
- full compiler toolchain unless the image is explicitly developer-focused

## Installer And First-Run Policy

Installation must be approachable for non-Linux users.

Required user experience:

- clear "Try Anemone" and "Install Anemone" boot choices
- graphical installer with simple disk choices
- safe defaults for EFI, encryption, locale, keyboard, timezone, and user setup
- visible warning before destructive disk operations
- first-run checklist for network, updates, display scaling, online accounts,
  printer setup, and Microsoft/Azure/.NET readiness

Debian Installer is acceptable for internal testing. A friendlier installer or
guided first-run layer is required before presenting the distro as suitable for
Windows/macOS migration at organization scale.

## Stability Gates

A release candidate is not ready until these checks pass repeatedly:

- clean build from a purged live-build tree
- no packages from testing or sid
- no unsigned or globally trusted third-party repositories
- `apt update` succeeds in the live session and installed system
- GNOME login works on Wayland and fallback X11 where supported
- PipeWire audio works and no PulseAudio/WirePlumber conflict exists
- Wi-Fi, Bluetooth, printer discovery, suspend/resume, and display scaling are
  smoke tested
- Azure CLI runs `az version`
- .NET runs `dotnet --info` and can create/build a console project
- live installer launches and completes in a VM
- installed system boots, updates, and reboots cleanly

## Short Description

Anemone Linux is a Debian Stable based enterprise workstation for organizations
moving to Linux while keeping Azure, .NET, Microsoft 365, and familiar corporate
workflows within reach.
