#==============================================================================#
#>        File: lib/install_helpers.sh                                         #
#> Description: Functions used by install scripts.                             #
#>      Author: Evan Gray                                                      #
#==============================================================================#

abort() {
    local msg=("$@")

    printf "%s\n" "${msg[@]}" >&2
    exit 1
}

print_help() {
    echo $USAGE
    echo "$( < $INSTALL_PATH/lib/help_menu.txt )"

    exit 0
}

array_includes() {
    local match="$1"
    local element
    shift

    for element; do [[ "$element" == "$match" ]] && return 0; done

    return 1
}

is_ignored() {
    local file="$1"
    local f

    if [[ -z $IGNORE ]]; then
        return 1
    fi

    for f in "${IGNORE[@]}"; do
        if [[ $f == $file ]]; then
            return 0
        fi
    done

    return 1
}

git_directory_is_clean() {
    # FIXME this isn't working properly now... weird.
    # taken from https://www.spinics.net/lists/git/msg142043.html
    # Update the index
    local err=0

    git update-index -q --ignore-submodules --refresh

    # Disallow unstaged changes in the working tree
    if ! git diff-files --quiet --ignore-submodules --; then
        echo >&2 "You have unstaged changes."
        git diff-files --name-status -r --ignore-submodules -- >&2
        err=1
    fi

    # Disallow uncommitted changes in the index
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --; then
        echo >&2 "Your index contains uncommitted changes."
        git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
        err=1
    fi

    if (( $err == 1 )); then
        echo >&2 "Please commit or stash them."
    fi

    return $err
}

validate_constant() {
    local const=$1

    if [[ -z ${!const} ]]; then
        abort "$const must be set in $RC_FILE to use this functionality!"
    fi
}

