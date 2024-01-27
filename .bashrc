# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Shell Options
#
# See man bash for more options...
#
# Don't wait for job termination notification
# set -o notify
#
# Don't use ^D to exit
# set -o ignoreeof
#
# Use case-insensitive filename globbing
# shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell
#
# vi-like command line editing
set -o vi
#
# update environment when graphical window changes size
shopt -s checkwinsize
#
# TTY flow control settings
stty -ixon
stty ixany

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
[[ -f /etc/bash_completion ]] && . /etc/bash_completion

# History Options
#
# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls'
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Aliases
#
# Some people use a different file for aliases
# if [ -f "${HOME}/.bash_aliases" ]; then
#   source "${HOME}/.bash_aliases"
# fi
#
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
#
# Default to human readable figures
# alias df='df -h'
# alias du='du -h'
#
# Misc :)
# alias less='less -r'                          # raw control characters
# alias whence='type -a'                        # where, of a sort
alias grep='grep --color=auto'                # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour
#
# Some shortcuts for different directory listings
# alias ls='ls -hF --color=tty'                 # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
# alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #
alias ls='ls --group-directories-first --color=auto'
alias lsports='ls -l /dev/tty[AURS]*'
#
# Deal with directories named for the current date
alias mkdirtoday='mkdir `date +%Y-%m-%d`'
alias cdtoday='cd `date +%Y-%m-%d`'
#
# TMUX aliases
alias tl='tmux ls'
alias ta='TMUX=; tmux attach -dt'
alias tn='TMUX=; tmux new -s'
#
# General purpose aliases
alias echoerr='>&2 echo'
alias my_ips="ip addr | awk '/inet/{print \$2}'"
alias pushtemp='td=$(mktemp -d) && pushd $td'
alias poptemp='popd && rm -rf $td'
alias hd-t32="hexdump -e '\"%016.16_ax\"\"| \" 8/4 \"%08x \"' -e '\" \" 32/1 \"%_p\"\"\n\"'"
#
# ARCH aliases
#alias systemctl='systemctl --no-pager'
#alias pacman='pacman --color auto'
#
# curl helpers
alias curlputjson='curl -w "\ncode: %{http_code}\n" -X PUT -H "Content-Type: application/json"'
alias curldeletejson='curl -w "\ncode: %{http_code}\n" -X DELETE -H "Content-Type: application/json"'
alias curlpostjson='curl -w "\ncode: %{http_code}\n" -X POST -H "Content-Type: application/json"'
#
# ssh for dev hosts with frequently changing keys
alias ssh-nohostkey='ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scp-nohostkey='scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

alias flvpn='sudo openvpn --config .config/flSense-UDP4-1194-matt.liss-config.ovpn'

# Functions
#
# Source bash functions from their own file
[[ -f "${HOME}/.bash_functions" ]] && . "${HOME}/.bash_functions"

# Host specific configuration
#
# Allow .bashrc_<hostname> to contain host specific config
[[ -f "${HOME}/.bashrc_`hostname`" ]] && . "${HOME}/.bashrc_`hostname`"

export EDITOR="vim"
export PATH=~/bin:~/workspace/github/devtools:~/workspace/bin:~/.local/bin:$PATH


export CMAKE_EXPORT_COMPILE_COMMANDS=1

# sigrok config
export SIGROKDECODE_DIR=/home/mliss/.libsigrokdecode

# Python setup
#
export PYTHONSTARTUP=~/.pystartup

# git prompt config
. ~/.git-completion.bash
. ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_HIDE_IF_PWD_IGNORED=1
export GIT_PS1_SHOWCOLORHINTS=1

if [[ ${EUID} == 0 ]] ; then
    PS1='\[\e[0;31m\]\u\[\e[0;34m\]@\[\e[0;32m\]\h\[\e[0;36m\]:\w \$\[\e[0m\] '
    export PROMPT_COMMAND='__git_ps1 "$(rv=$?; if [ $rv -ne 0 ]; then echo -e "\[\e[0;31m\][\[\e[0m\]$rv\[\e[0;31m\]]"; fi)\[\e[0;31m\]\u\[\e[0;34m\]@\[\e[0;32m\]\h\[\e[0;36m\]:\W\[\e[0m\]" " \$ "'
else
    PS1='\[\e[0;33m\]\u\[\e[0;34m\]@\[\e[0;32m\]\h\[\e[0;36m\]:\w \$\[\e[0m\] '
    export PROMPT_COMMAND='__git_ps1 "$(rv=$?; if [ $rv -ne 0 ]; then echo -e "\[\e[0;31m\][\[\e[0m\]$rv\[\e[0;31m\]]"; fi)\[\e[0;33m\]\u\[\e[0;34m\]@\[\e[0;32m\]\h\[\e[0;36m\]:\W\[\e[0m\]" " \$ "'
fi
