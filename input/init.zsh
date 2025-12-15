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
    emulate -LR zsh
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
    emulate -LR zsh
    if [[ ${LBUFFER} == *.. ]]; then
        LBUFFER+='/..'
    else
        LBUFFER+='.'
    fi
}
zle -N double-dot-expand

# Inserts 'sudo ' at the beginning of the line.
function prepend-sudo {
if [[ "$BUFFER" != su(do|)\ * ]]; then
	BUFFER="sudo $BUFFER"
	(( CURSOR += 5 ))
fi
}
zle -N prepend-sudo

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search


# Keybinds for emacs and vi insert mode
for keymap in 'emacs' 'viins'; do
	bindkey -M "$keymap" "$key_info[Insert]" overwrite-mode
	bindkey -M "$keymap" "$key_info[Delete]" delete-char
	bindkey -M "$keymap" "$key_info[Backspace]" backward-delete-char

	bindkey -M "$keymap" "$key_info[Left]" backward-char
	bindkey -M "$keymap" "$key_info[Right]" forward-char

	bindkey "^[[A" up-line-or-beginning-search # Up
	bindkey "^[[B" down-line-or-beginning-search # Down

	# Expand history on space.
	bindkey -M "$keymap" ' ' magic-space

	# Clear screen.
	bindkey -M "$keymap" "$key_info[Control]L" clear-screen

	# Expand command name to full path.
	for key in "$key_info[Escape]"{E,e};do
		bindkey -M "$keymap" "$key" expand-cmd-path
	done

	# Duplicate the previous word.
	autoload -Uz copy-earlier-word
	zle -N copy-earlier-word
	for key in "$key_info[Escape]"{M,m};do
		# bindkey -M "$keymap" "$key" copy-prev-shell-word
		bindkey -M "$keymap" "$key" copy-earlier-word
	done

	# Use a more flexible push-line.
	for key in "$key_info[Control]Q" "$key_info[Escape]"{q,Q};do
		bindkey -M "$keymap" "$key" push-line-or-edit
	done

	# Bind Shift + Tab to go to the previous menu item.
	bindkey -M "$keymap" "$key_info[BackTab]" reverse-menu-complete

	# Display an indicator when completing.
	bindkey -M "$keymap" "$key_info[Control]I" expand-or-complete-with-dots

	# Expand .... to ../..
	bindkey -M "$keymap" "." double-dot-expand

	# use ctrl-z to toggle the program instance
	bindkey -M "$keymap" "^Z" fancy-ctrl-z

	# Insert 'sudo ' at the beginning of the line.
	bindkey -M "$keymap" "${key_info[Escape]}s" prepend-sudo

	# control-space expands all aliases, including global
	# bindkey -M "$keymap" "$key_info[Control] " glob-alias

	# These are mainly for viins mode
	bindkey -M "$keymap" "$key_info[Control]W"   backward-delete-word
	bindkey -M "$keymap" "$key_info[Control]U"   backward-kill-line
	bindkey -M "$keymap" "$key_info[Control]K"   kill-line

done

# aliases
alias mux=tmuxinator

# End of File
