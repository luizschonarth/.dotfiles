#! /usr/bin/env bash

print_error() {
    local source=$1
    echo -e "\e[31mERROR:\e[0m couldn't link ${source}."
}

print_success() {
    local source=$1
    local target=$2
    echo -e "\e[32mOK:\e[0m linked ${source} to ${target}."
}

create_backup() {
    local source=$1
    echo -e "\e[1;33mINFO:\e[0m creating backup of ${source}."
    cp "$source" "${source}~" 
}

link_files() {
    local source_dir=$1
    local target_dir=$2
    local names=$(ls -A "$source_dir")

    echo -e "\e[1;33mINFO:\e[0m linking to ${target_dir}."
    
    for n in ${names[@]}
    do
        local target="$target_dir/$n"

        # Create backup of file/dir if it is not a symlink
        if [[ -f "$target" || -d "$target" ]]; then
            [[ -L "$target" ]] || create_backup $target
        fi

        # Link file and print error message if return code > 0, otherwise print success message
        ln -sf "$source_dir/$n" "$target"
        [[ $? != 0 ]] && print_error $n || print_success $n $target

        # Remove infinite link loop caused by symlinking dirs that are already linked
        [ -d "$source_dir/$n" ] && unlink "$source_dir/$n/$n"
    done
}

config_dir="$HOME/.config"
base_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

link_files "$base_dir/home.d"   "$HOME"
link_files "$base_dir/config.d" "$config_dir"

