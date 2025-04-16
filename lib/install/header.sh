# ------------------------------------------------------
# Header
# ------------------------------------------------------
_writeLogHeader "Instalacion"
_writeLog 0 "Instalacion comenzada"

clear
echo -e "${GREEN}"
cat <<"EOF"
   __  _____  _____      __  ___       __  ____ __
  /  |/  / / / / / | /| / / / _ \___  / /_/ _(_) /__ ___
 / /|_/ / /_/_  _/ |/ |/ / / // / _ \/ __/ _/ / / -_|_-<
/_/  /_/____//_/ |__/|__/ /____/\___/\__/_//_/_/\__/___/

EOF
echo "para Hyprland"
echo "por Stephan Raabe"
echo "adaptado al español por Antonio Morán"
echo -e "${NONE}"

echo "Version: $version"
echo "Plataforma: $install_platform"
echo
# echo ":: You're running the script in $(pwd)"
if [[ $(_check_update) == "true" ]]; then
    _writeLog 0 "Una instalacion existente de ML4W Dotfiles ha sido detectada."
    _writeMessage "Este script le guiará a través del proceso de actualización de ML4W Dotfiles."
else
    _writeLog 0 "Instalacion inicial de ML4W Dotfiles comenzada."
    _writeMessage "Este script le guiará a través del proceso de actualización de ML4W Dotfiles."
fi
