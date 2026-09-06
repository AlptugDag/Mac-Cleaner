.PHONY: install uninstall run dry-run

PREFIX ?= /usr/local/bin

install:
	@echo "Installing mac-cleaner to $(PREFIX)/mac-cleaner..."
	@cp clean.sh $(PREFIX)/mac-cleaner
	@chmod +x $(PREFIX)/mac-cleaner
	@echo "Done! You can now run 'mac-cleaner' from anywhere."

uninstall:
	@echo "Removing mac-cleaner from $(PREFIX)/mac-cleaner..."
	@rm -f $(PREFIX)/mac-cleaner
	@echo "Done!"

run:
	./clean.sh --yes

dry-run:
	./clean.sh
