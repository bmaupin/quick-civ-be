#!/usr/bin/env bash

# Exit right away if there are any errors (e.g. yq or another tool isn't installed)
set -e

# Exit if not running under bash
if [ -z "$BASH_VERSION" ]; then
    echo "This script must be run with bash" >&2
    exit 1
fi

# Build the mod in a temporary directory
source "$(dirname "$(which "$0")")/build.sh"

mod_name_version="$(echo "${mod_name} (v ${mod_version})" | tr '[:upper:]' '[:lower:]')"

# Detect whether we're using native or Proton
if [[ -f "/home/$USER/.steam/steam/steamapps/common/Sid Meier's Civilization Beyond Earth/CivBE" ]]; then
    user_directory="/home/${USER}/.local/share/aspyr-media/Sid Meier's Civilization Beyond Earth"
elif [[ -f "/home/$USER/.steam/steam/steamapps/common/Sid Meier's Civilization Beyond Earth/CivilizationBE_DX11.exe" ]]; then
    user_directory="/home/${USER}/.steam/steam/steamapps/compatdata/65980/pfx/drive_c/users/steamuser/Documents/My Games/Sid Meier's Civilization Beyond Earth"
else
    echo "Error: Beyond Earth not found"
    exit 1
fi

# Inject the current timestamp into the mod teaser text. This makes it easier to tell if
# the mod has been updated when doing development.
sed -i "s|\(<Teaser>\)[^<]*\(</Teaser>\)|\1$(date)\2|" "${temp_dir}/${mod_name_version}.modinfo"

echo "Copying mod files ..."
mod_directory="${user_directory}/MODS/${mod_name_version}"
rm -rf "${mod_directory}"
mv "${temp_dir}" "${mod_directory}"

# This hack seems to be enough to signal to the game that there have been changes to mods 🤷‍♂️
touch "${user_directory}/MODS/test"
rm "${user_directory}/MODS/test"
