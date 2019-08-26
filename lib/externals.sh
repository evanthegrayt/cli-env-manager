
clone_vim() {
    log "Cloning vim from $VIM_REPO"
    git clone --recursive $VIM_REPO $HOME/.vim
}

clone_shell_framework() {
    local directory="$1"
    local url="$2"
    local custom_url="$3"

    if [[ -d $directory ]]; then
        log "$directory already exists."
    else
        log "Installing $directory from $url"
        git clone $url $directory
    fi

    if [[ -z $custom_url ]]; then
        log "No custom directory set $directory."
    else
        if [[ -d $directory/custom ]]; then
            rm -rf $directory/custom
        fi
        log "Installing $directory/custom from $custom_url"
        git clone --recursive $custom_url $directory/custom
    fi
}

install_mac_work_stuff() {
    local tap
    local cask

    if [[ -n $SCREENSHOT_DIR ]]; then
        log "Changing Screenshot directory to $SCREENSHOT_DIR"
        [[ -d $SCREENSHOT_DIR ]] || mkdir -p $SCREENSHOT_DIR
        defaults write com.apple.screencapture location $SCREENSHOT_DIR
        killall SystemUIServer
    else
        log "SCREENSHOT_DIR not set."
    fi

    log "Installing xcode command line tools"
    xcode-select --install
    log "Installing Homebrew"
    /usr/bin/ruby -e $( curl -fsSL "$BREW" )

    if ! which -s rvm >/dev/null; then
        log "Installing rvm"
        'curl' -sSL https://get.rvm.io | bash -s stable
    fi

    # TODO Dry this up.
    if (( ${#BREW_TAPS[@]} == 0 )); then
        log 'No brew taps to install.'
    else
        for tap in "${BREW_TAPS[@]}"; do
            log "Installing [$tap] with brew"
            brew install $tap
        done
    fi

    if (( ${#BREW_CASKS[@]} == 0 )); then
        log 'No brew casks to install.'
    else
        for cask in "${BREW_CASKS[@]}"; do
            log "Installing [$cask] with brew cask"
            brew cask install $cask
        done
    fi
}

clone_github_stuff() {
    local repo
    local repo_name

    for repo in "${GIT_REPOS[@]}"; do
        repo_name=${repo##*/}
        if [[ -d "$REPO_DIR/$repo_name" ]]; then
            log "$repo is already cloned in $REPO_DIR"
            continue
        fi
        log "Cloning $repo"
        git clone "$repo.git" "$REPO_DIR/$repo_name"
        # TODO clean this up, and allow for more stuff, maybe `bundle install`.
        if [[ -f "$REPO_DIR/$repo_name/Rakefile" ]]; then
            log "Running Rakefile for $repo"
            pushd "$REPO_DIR/$repo_name"
            rake
            popd
        fi
        if [[ -f "$REPO_DIR/$repo_name/Makefile" ]]; then
            log "Running Makefile for $repo"
            pushd "$REPO_DIR/$repo_name"
            make
            popd
        fi
    done
}

install_ruby_gems() {
    local gem

    # TODO probably create a Gemfile instad of this and run bundle install?
    for gem in ${RUBY_GEMS[@]}; do
        gem install $gem
        log "Installing ruby gem [$gem]"
    done
}

