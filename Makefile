INSTALL_DIR=~/.local/bin/qbash
FILE_NAME=qbash.sh

all:
	@echo "Please run 'make install'"

install:
	@echo ""
	mkdir -p $(INSTALL_DIR)
	cp $(FILE_NAME) $(INSTALL_DIR)
	echo "# qbash             #" >> ~/.bashrc
	echo "QB_HOME=~/projects/memoir" >> ~/.bashrc
	echo "alias qb=\". $(INSTALL_DIR)/qbash.sh\"" >> ~/.bashrc
	echo "# qbash END #" >> ~/.bashrc
	exec bash
	@echo ''
	@echo 'USAGE:'
	@echo '------'

install-accessories:
	@echo ""
	mkdir -p $(INSTALL_DIR)
	cp accessories/*.sh $(INSTALL_DIR)
	echo "# qbash accessories #" >> ~/.bashrc
	echo "alias delegate=\". $(INSTALL_DIR)/delegate.sh\"" >> ~/.bashrc
	echo "# qbash END #" >> ~/.bashrc
	@echo ''
	@echo 'USAGE:'
	@echo '------'

install-full:
	make install-accessories
	make install

reinstall:
	make uninstall
	make install

reinstall-full:
	make uninstall
	make install-full

uninstall:
	rm -rf $(INSTALL_DIR)
	sed -i '/qbash/ d' ~/.bashrc

.PHONY: all install
