#
# ~/.bashrc
#


# export PATH="/home/adrian/miniconda3/bin:$PATH"  # commented out by conda initialize

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \w]\$ '

# >>> Lazy Load Conda >>>
conda() {
    # 1. Remove this wrapper function so it only runs once
    unset -f conda

    # 2. Run the actual Conda initialization
    __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup

    # 3. Execute the actual conda command the user requested
    conda "$@"
}
# <<< Lazy Load Conda <<<

export PATH="$HOME/bin:$PATH"

## Only source the file if it exists
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi


# Go Environment Setup
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin" # THIS FIXES COBRA-CLI

export PATH="$PATH:/bin"

eval "$(starship init bash)"
