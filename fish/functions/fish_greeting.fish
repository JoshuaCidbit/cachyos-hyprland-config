function fish_greeting

    cat ~/.cache/wal/sequences 2>/dev/null

    set_color $color1
    set_color normal
    ~/.config/fastfetch/gen_fastfetch.sh 2>/dev/null
    fastfetch --key-padding-left 5
    
end
      
