all:
	@echo "Please run 'make install'"

install:
	@echo ""
	echo "# bb-accessories             #" >> ~/.bashrc
	echo "alias forest=\"tree -L 3\"" >> ~/.bashrc
	echo "function mcd"
	echo "{"
	echo "	command mkdir $1 && $2"
	echo "}"
	echo "# bb-accessories END #" >> ~/.bashrc
	exec bash
	@echo ''
	@echo 'USAGE:'
	@echo '------'

uninstall:
	sed -i '/bb-accessories/ d' ~/.bashrc

.PHONY: all install
