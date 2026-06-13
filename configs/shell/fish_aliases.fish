# Fish shell aliases — place in ~/.config/fish/conf.d/aliases.fish

abbr --add c    clear
abbr --add ..   'cd ..'
abbr --add ...  'cd ../..'

# Package management
abbr --add update     'sudo nala update && sudo nala upgrade'
abbr --add install    'sudo nala install'
abbr --add remove     'sudo nala remove'
abbr --add search     'nala search'
abbr --add autoremove 'sudo nala autoremove'

# System info
abbr --add speedtest  'speedtest-cli --simple'
abbr --add ff         fastfetch

# Config shortcuts
abbr --add i3config   'gedit ~/.config/i3/config'
abbr --add polyconfig 'gedit ~/.config/polybar/config.ini'
abbr --add aliasrc    'gedit ~/.config/shell/aliases.fish'

# ls → eza
abbr --add ls  'eza --icons --group-directories-first'
abbr --add ll  'eza --icons --group-directories-first -la --git'
abbr --add lt  'eza --icons --tree --level=2'

# cat → bat
abbr --add cat 'bat --style=plain'

# Safety
abbr --add rm 'rm -i'
abbr --add cp 'cp -i'
abbr --add mv 'mv -i'

# Launch fastfetch on interactive shell start
if status is-interactive
    fastfetch
end
