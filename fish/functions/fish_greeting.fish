function fish_greeting

    cat ~/.cache/wal/sequences 2>/dev/null

    set_color $color1
    echo '     ______           __          __  _       '
    echo '    / ____/___ ____  / /__  _____/ /_(_)___ _ '
    echo '   / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/ '
    echo '  / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /  '
    echo '  \____/\__,_/\___/_/\___/____/\__/_/\__,_/   '
    set_color normal
    ~/.config/fastfetch/gen_fastfetch.sh 2>/dev/null
    fastfetch --key-padding-left 5
    
end