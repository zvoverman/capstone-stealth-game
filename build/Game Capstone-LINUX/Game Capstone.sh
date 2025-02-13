#!/bin/sh
echo -ne '\033c\033]0;Game Capstone\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Game Capstone.x86_64" "$@"
