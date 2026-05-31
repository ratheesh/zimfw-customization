# Copyright (c) 2023 Ratheesh <ratheeshreddy@gmail.com>
# Author: Ratheesh S
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# utilities -> TODO: move to custom module
expand-or-complete-with-dots() {
    # emulate -LR zsh
    print -Pn "%{%B%F{red}......%f%b%}"
    sleep 0.15
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots

fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z

# Expands .... to ../..
double-dot-expand() {
    # emulate -LR zsh
    if [[ ${LBUFFER} == *.. ]]; then
        LBUFFER+='/..'
    else
        LBUFFER+='.'
    fi
}
zle -N double-dot-expand

# Toggles 'sudo ' at the beginning of the line.
function prepend-sudo() {
    if [[ "$BUFFER" == sudo\ * ]]; then
        BUFFER="${BUFFER#sudo }"
        (( CURSOR -= 5 ))
    else
        BUFFER="sudo $BUFFER"
        (( CURSOR += 5 ))
    fi
}
zle -N prepend-sudo

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

autoload -Uz quote-line quote-region
zle -N quote-line
zle -N quote-region

unalias run-help 2>/dev/null
autoload -Uz run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-sudo


autoload -Uz copy-earlier-word
zle -N copy-earlier-word

autoload -Uz smart-insert-last-word
zle -N insert-last-word smart-insert-last-word

# Keybinds for emacs, vi insert, and vi normal mode
for keymap in 'emacs' 'viins' 'vicmd'; do
    bindkey -M "$keymap" "$key_info[Delete]"    delete-char
    bindkey -M "$keymap" "$key_info[Backspace]" backward-delete-char

    bindkey -M "$keymap" "$key_info[Left]"  backward-char
    bindkey -M "$keymap" "$key_info[Right]" forward-char

    bindkey -M "$keymap" "$key_info[Up]"    up-line-or-beginning-search
    bindkey -M "$keymap" "$key_info[Down]"  down-line-or-beginning-search

    bindkey -M "$keymap" "$key_info[Home]"     beginning-of-line
    bindkey -M "$keymap" "$key_info[End]"      end-of-line
    bindkey -M "$keymap" "$key_info[PageUp]"   up-line-or-history
    bindkey -M "$keymap" "$key_info[PageDown]" down-line-or-history

    # Ctrl+Left/Right: word movement (xterm-compatible sequences)
    bindkey -M "$keymap" "^[[1;5D" backward-word
    bindkey -M "$keymap" "^[[1;5C" forward-word
    bindkey -M "$keymap" "^[^[[D"  backward-word
    bindkey -M "$keymap" "^[^[[C"  forward-word

    # Clear screen.
    bindkey -M "$keymap" "$key_info[Control]L" clear-screen

    # Expand command name to full path.
    for key in "$key_info[Escape]"{E,e}; do
        bindkey -M "$keymap" "$key" expand-cmd-path
    done

    # Duplicate the previous word.
    for key in "$key_info[Escape]"{M,m}; do
        bindkey -M "$keymap" "$key" copy-earlier-word
    done

    # Use a more flexible push-line.
    for key in "$key_info[Control]Q" "$key_info[Escape]"{q,Q}; do
        bindkey -M "$keymap" "$key" push-line-or-edit
    done

    # Bind Shift + Tab to go to the previous menu item.
    bindkey -M "$keymap" "$key_info[BackTab]" reverse-menu-complete

    # Display an indicator when completing.
    bindkey -M "$keymap" "$key_info[Control]I" expand-or-complete-with-dots

    # Toggle 'sudo ' at the beginning of the line.
    bindkey -M "$keymap" "${key_info[Escape]}s" prepend-sudo

    # Quote current line
    bindkey -M "$keymap" "${key_info[Escape]}'" quote-line

    # Inline help for current command
    bindkey -M "$keymap" "${key_info[Escape]}h" run-help

    bindkey -M "$keymap" "${key_info[Escape]}." insert-last-word

    bindkey -M "$keymap" "$key_info[Control]W" backward-kill-word
    bindkey -M "$keymap" "$key_info[Control]U" backward-kill-line
    bindkey -M "$keymap" "$key_info[Control]K" kill-line

    # use ctrl-z to toggle the program instance
    bindkey -M "$keymap" "^Z" fancy-ctrl-z

    # vicmd: skip bindings that conflict with vi normal-mode keys
    if [[ $keymap != vicmd ]]; then
        bindkey -M "$keymap" "$key_info[Insert]" overwrite-mode
        # Expand history on space.
        bindkey -M "$keymap" ' ' magic-space
        # Expand .... to ../..
        bindkey -M "$keymap" "." double-dot-expand
    fi
done

# Safe paste: neutralize special chars in pasted text
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# aliases
alias mux=tmuxinator

# End of File
