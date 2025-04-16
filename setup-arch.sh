#!/bin/bash
clear

# -----------------------------------------------------
# Repository
# -----------------------------------------------------
repo="anmomu92/ml4w-dotfiles-espanol"

# -----------------------------------------------------
# Download Folder
# -----------------------------------------------------
download_folder="$HOME/.amm92"

# Create download_folder if not exists
if [ ! -d $download_folder ]; then
    mkdir -p $download_folder
fi

# Get latest tag from GitHub
get_latest_release() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" | # Get latest release from GitHub api
        grep '"tag_name":' |                                             # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                     # Pluck JSON value
}

# Get latest zip from GitHub
get_latest_zip() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" | # Get latest release from GitHub api
        grep '"zipball_url":' |                                          # Get tag line
        sed -E 's/.*"([^"]+)".*/\1/'                                     # Pluck JSON value
}

# Check if package is installed
_isInstalled() {
    package="$1"
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"
    if [ -n "${check}" ]; then
        echo 0 #'0' means 'true' in Bash
        return #true
    fi
    echo 1 #'1' means 'false' in Bash
    return #false
}

# Check if command exists
_checkCommandExists() {
    package="$1"
    if ! command -v $package >/dev/null; then
        return 1
    else
        return 0
    fi
}

# Install required packages
_installPackages() {
    toInstall=()
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed."
            continue
        fi
        toInstall+=("${pkg}")
    done
    if [[ "${toInstall[@]}" == "" ]]; then
        # echo "All pacman packages are already installed.";
        return
    fi
    printf "Package not installed:\n%s\n" "${toInstall[@]}"
    sudo pacman --noconfirm -S "${toInstall[@]}"
}

# install yay if needed
_installYay() {
    _installPackages "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/yay.git $download_folder/yay
    cd $download_folder/yay
    makepkg -si
    cd $temp_path
    echo ":: yay has been installed successfully."
}

# Required packages for the installer
packages=(
    "wget"
    "unzip"
    "gum"
    "rsync"
    "git"
)

latest_version=$(get_latest_release)

# Some colors
GREEN='\033[0;32m'
NONE='\033[0m'

# Header
echo -e "${GREEN}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF
echo "Adaptación de los dotfiles de ML4W al español."
echo -e "${NONE}"
while true; do
    read -p "¿QUIERE COMENZAR LA INSTALACIÓN AHORA? (Ss/Nn): " yn
    case $yn in
        [Ss]*)
            echo ":: Instalación comenzada."
            echo
            break
            ;;
        [Nn]*)
            echo ":: Instalación cancelada."
            exit
            break
            ;;
        *)
            echo ":: Por favor, responda sí o no."
            ;;
    esac
done

# Create Download folder if not exists
if [ ! -d $download_folder ]; then
    mkdir -p $download_folder
    echo ":: Directorio $download_folder creado."
fi

# Remove existing download folder and zip files
if [ -f $download_folder/dotfiles-main.zip ]; then
    rm $download_folder/dotfiles-main.zip
fi
if [ -f $download_folder/dotfiles-dev.zip ]; then
    rm $download_folder/dotfiles-dev.zip
fi
if [ -f $download_folder/dotfiles.zip ]; then
    rm $download_folder/dotfiles.zip
fi
if [ -d $download_folder/dotfiles ]; then
    rm -rf $download_folder/dotfiles
fi
if [ -d $download_folder/dotfiles_temp ]; then
    rm -rf $download_folder/dotfiles_temp
fi
if [ -d $download_folder/dotfiles-main ]; then
    rm -rf $download_folder/dotfiles-main
fi
if [ -d $download_folder/dotfiles-dev ]; then
    rm -rf $download_folder/dotfiles-dev
fi

# Synchronizing package databases
sudo pacman -Sy
echo

# Install required packages
echo ":: Comprobando que los paquetes requeridos estén instalados..."
_installPackages "${packages[@]}"

# Install yay if needed
if _checkCommandExists "yay"; then
    echo ":: yay ya está instalado."
else
    echo ":: El instalador requiere de yay. yay será instalado ahora."
    _installYay
fi
echo

# Select the dotfiles version
echo "Por favor, elija entre: "
echo "- ML4W Dotfiles for Hyprland $latest_version (la última release estable)"
echo "- ML4W Dotfiles for Hyprland Rolling Release (la rama main, incluyendo los últimos commits)"
echo
version=$(gum choose "main-release" "rolling-release" "CANCEL")
if [ "$version" == "main-release" ]; then
    echo ":: Instalando la Main Release"
    yay -S --noconfirm ml4w-hyprland
elif [ "$version" == "rolling-release" ]; then
    echo ":: Instalando la Rolling Release"
    yay -S ml4w-hyprland-git
elif [ "$version" == "CANCEL" ]; then
    echo ":: Configuración cancelada."
    exit 130
else
    echo ":: Configuración cancelada."
    exit 130
fi
echo ":: Instalación completa."
echo
# Start Spinner
gum spin --spinner dot --title "Comenzando la configuración ahora..." -- sleep 3

# Start setup
ml4w-hyprland-setup -p arch
