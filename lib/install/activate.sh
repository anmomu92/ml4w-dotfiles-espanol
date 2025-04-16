#!/bin/bash
#     _        _   _            _
#    / \   ___| |_(_)_   ____ _| |_ ___
#   / _ \ / __| __| \ \ / / _` | __/ _ \
#  / ___ \ (__| |_| |\ V / (_| | ||  __/
# /_/   \_\___|\__|_| \_/ \__,_|\__\___|
#

clear
dot_folder=""

_activate_dotfiles_folder() {
    echo ":: Activando $dot_folder ahora..."
    echo

    # Check home
    files=$(ls -a $HOME/$dot_folder)
    for f in $files; do
        if [ ! "$f" == "." ] && [ ! "$f" == ".." ] && [ ! "$f" == ".config" ]; then
            if [ -f $HOME/$dot_folder/$f ]; then
                # echo ":: Checking for file $HOME/$f"
                if [ -L $HOME/$f ]; then
                    rm $HOME/$f
                fi
                if [ -f ~/$f ]; then
                    rm $HOME/$f
                fi
                ln -s $HOME/$dot_folder/$f $HOME
                if [ -L $HOME/$f ]; then
                    echo ":: SUCCESS $HOME/$dot_folder/$f -> $HOME/$f"
                else
                    echo ":: ERROR $HOME/$dot_folder/$f -> $HOME/$f"
                fi
            fi
        fi
    done

    # Check .config
    files=$(ls -a $HOME/$dot_folder/.config)
    for f in $files; do
        if [ ! "$f" == "." ] && [ ! "$f" == ".." ]; then
            if [ -d $HOME/$dot_folder/.config/$f ]; then
                # echo ":: Checking for directory $HOME/.config/$f"
                if [ -L $HOME/.config/$f ]; then
                    rm $HOME/.config/$f
                fi
                if [ -f $HOME/.config/$f ]; then
                    rm $HOME/.config/$f
                fi
                if [ -d $HOME/.config/$f ]; then
                    rm -rf $HOME/.config/$f
                fi
                ln -s $HOME/$dot_folder/.config/$f $HOME/.config
                if [ -L $HOME/.config/$f ]; then
                    echo ":: SUCCESS $HOME/$dot_folder/.config/$f -> $HOME/.config/$f"
                else
                    echo ":: ERROR $HOME/$dot_folder/.config/$f -> $HOME/.config/$f"
                fi
            fi
            if [ -f $HOME/$dot_folder/.config/$f ]; then
                # echo ":: Checking for file $HOME/.config/$f"
                if [ -L $HOME/.config/$f ]; then
                    rm $HOME/.config/$f
                fi
                if [ -f $HOME/.config/$f ]; then
                    rm $HOME/.config/$f
                fi
                ln -s $HOME/$dot_folder/.config/$f $HOME/.config
                if [ -L $HOME/.config/$f ]; then
                    echo ":: SUCCESS $HOME/$dot_folder/.config/$f -> $HOME/.config/$f"
                else
                    echo ":: ERROR $HOME/$dot_folder/.config/$f -> $HOME/.config/$f"
                fi
            fi
        fi
    done

    # Write dot folder into settings
    echo "$dot_folder" >$HOME/$dot_folder/.config/ml4w/settings/dotfiles-folder.sh

    stow --dir="$HOME/$dot_folder" --target="$HOME" .
    echo
    echo ":: Activation of ~/$dot_folder completed. "
    echo
    echo -e "${GREEN}"
    figlet -f smslant "Logout"
    echo -e "${NONE}"
    echo "A new login into your system is recommended."
    echo
    if gum confirm "Do you want to exit your system now?"; then
        gum spin --spinner dot --title "Logout has started..." -- sleep 3
        killall -9 Hyprland
    elif [ $? -eq 130 ]; then
        exit 130
    else
        _writeSkipped
    fi
    echo ""

    echo

    exit
}

_define_dotfiles_folder() {
    dot_folder_tmp=$(gum input --value "$dot_folder" --placeholder "Escriba el nombre de su directorio de instalación.")
    dot_folder=${dot_folder_tmp//[[:blank:]]/}
    if [ $dot_folder == "cancel" ]; then
        exit
    elif [ $dot_folder == ".ml4w-hyprland" ]; then
        echo ":: El directorio .ml4w-hyprland no está permitido."
        _define_dotfiles_folder
    else
        _confirm_dotfiles_folder
    fi
}

_confirm_dotfiles_folder() {
    if [ -d ~/$dot_folder ] && [ -d ~/$dot_folder/.config/ml4w ]; then
        echo ":: Directorio ~/$dot_folder seleccionado."
        echo
        if gum confirm "¿Quiere activar ahora?"; then
            _activate_dotfiles_folder
        else
            _writeCancel
            exit
        fi
    else
        echo "ERROR: El directorio no existe o no es compatible."
        echo "Por favor, actualice el nombre del directorio."
        echo
        _define_dotfiles_folder
    fi
}

figlet -f smslant "Activate"
echo ":: Puede activar una instalación ML4W Dotfiles existente."
echo
echo ":: Por favor, escriba el nombre del directorio de instalación, empezando desde su directorio HOME."
echo ":: (e.g., dotfiles o Documents/mydotfiles, ...)"
echo ":: Escriba cancel para salir."
echo
_define_dotfiles_folder
