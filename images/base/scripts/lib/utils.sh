function gow_log {
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") $*"
}

function join_by { local IFS="$1"; shift; echo "$*"; }
