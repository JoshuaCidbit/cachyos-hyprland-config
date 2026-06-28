if status is-interactive
    # Starship custom prompt
    starship init fish | source
    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source
    # Better ls
    alias ls='eza --icons --group-directories-first -1'
    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'
    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'
    abbr lmstudio 'nohup env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia lm-studio > /dev/null 2>&1 & disown'
    abbr code 'codium'
    abbr ps 'sudo pacman -S'
    abbr pr 'sudo pacman -R'
    abbr i 'yay -S'

    # Custom colours
    if set -q KITTY_LISTEN_ON
        kitty @ --to $KITTY_LISTEN_ON set-colors --all ~/.cache/wal/colors-kitty.conf 2>/dev/null
    end
    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
    
    # Custom fish config
    source ~/.config/caelestia/user-config.fish 2> /dev/null
end

fish_add_path --append $HOME/.lmstudio/bin

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/joshua/.lmstudio/bin
# End of LM Studio CLI section

