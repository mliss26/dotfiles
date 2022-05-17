# vim: set ft=sh:
#
# Bash Functions
#

repodo()
{
    if [ $# -lt 1 ]; then
        echo "usage: repodo <command(s) to run with repo forall>"
        return 1
    fi
    repo forall -p -c "$@"
}

dirdo()
{
    if [ $# -lt 3 ]; then
        echo "usage: dirdo <DIRS> -- <CMDS>"
        echo "    DIRS: Directories in which to descend"
        echo "    CMDS: Command(s) to run in each directory"
        return 1
    fi
    dir=()
    while [ $# -gt 0 ]; do
        if [ "$1" = "--" ]; then
            shift
            break;
        else
            dir+=($1)
            shift
        fi
    done
    if [ $# -lt 1 ]; then
        echo "error: must specify at least one command to run"
        return 1
    fi
    for d in "${dir[@]}"; do
        pushd $d >/dev/null
        tput bold
        echo "directory $d"
        tput sgr0
        eval $@
        popd >/dev/null
    done
}

get_event_pipe()
{
    evt="${1/ /_}"
    file="/tmp/shevt_$evt"
    [ -e $file ] || mkfifo $file
    echo $file
}

wfe()
{
    if [ $# -lt 1 ]; then
        echo "usage: wfe <event>"
        echo
        echo "    Wait for an event sent by another shell. Event can be any string"
        echo "    and must match that passed to sev for the wait to complete."
        echo
        return
    fi
    cat $(get_event_pipe $1)
}

sev()
{
    if [ $# -lt 1 ]; then
        echo "usage: sev <event>"
        echo
        echo "    Send an event to another shell. Event can be any string and must"
        echo "    match that passed to wfe for the wait to complete. sev will hang"
        echo "    until there is a process waiting for the same event."
        echo
        return
    fi
    echo $1 > $(get_event_pipe $1)
}

get_event_tcp_port()
{
    echo $(( $(crc16 $1) | 0x8000 ))
}

wfer()
{
    if [ $# -lt 1 ]; then
        echo "usage: wfer <event>"
        echo
        echo "    Wait for an event sent by another network host. Event can be any"
        echo "    string and must match that passed to sevr for the wait to complete."
        echo
        return
    fi
    nc -l -t $(get_event_tcp_port $1)
}

sevr()
{
    if [ $# -lt 1 ]; then
        echo "usage: sevr <host> <event>"
        echo
        echo "    Send an event to another network host. Event can be any string and"
        echo "    must match that passed to wfer for the wait to complete. sevr will"
        echo "    return immediately whether there is a process waiting for the same"
        echo "    event or not."
        echo
        return
    fi
    echo $2 | nc -t $1 $(get_event_tcp_port $2)
}

git_push_repo ()
{
    local repo=$1
    local path=$2
    local rmgit=false
    if [ -z "$repo" ]; then
        echo "usage: git_push_repo <repo.git> [path]"
        echo "  Push git repo to hal:/git/<path>/<repo.git> and fixup perms."
        echo "  <path> defaults to $USER if not supplied."
        return 1
    fi
    [ -z "$path" ] && path=$USER
    repo=${repo///}
    path=${path///}

    # clone a bare repo first
    if [[ $repo != *.git ]]; then
        git clone --bare $repo $repo.git
        rmgit=true
        repo=$repo.git
    fi

    # copy the bare repo and chown it
    rsync -av $repo hal:/tmp/
    echo "chowning $repo..."
    ssh -t hal "sudo sh -c 'chown -R git:git /tmp/$repo && mv /tmp/$repo /git/$path/'"

    # cleanup bare repo if we created it
    $rmgit && rm -vrf $repo.git

    echo "done"
    echo "remote available at ssh://git@ejtheta.net/git/$path/$repo"
}
