.PHONY: install clean help

install:
	rm -rf "$$HOME/.config/nvim"
	ln -s "$(CURDIR)" "$$HOME/.config/nvim"

clean:
	rm -rf "$$HOME/.local/share/nvim"

help:
	@printf '%s\n' 'install: symlink this repo to ~/.config/nvim' 'clean: remove ~/.local/share/nvim' 'help: show this message'
