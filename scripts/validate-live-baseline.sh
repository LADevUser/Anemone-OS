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

section "current user and groups"
id
printf 'USER=%s\n' "${USER:-}"
groups 2>&1
