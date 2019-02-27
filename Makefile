ifeq ($(PREFIX),)
    PREFIX := /usr/local/
endif


SOURCE_EXTRA_LIST := LICENSE.md Makefile README.md


.PHONY: all clean distclean install uninstall dist package zip


all: src/microca.sh
	@mkdir -p bin/
	@cp src/microca.sh bin/microca


clean:
	-@$(RM) -r bin/
	-@$(RM) -r build/

distclean: clean
	-@$(RM) -r dist/


install: bin/microca
	@sudo install -d $(DESTDIR)/$(PREFIX)/bin/
	@sudo install bin/microca $(DESTDIR)/$(PREFIX)/bin/

uninstall: $(DESTDIR)/$(PREFIX)/bin/microca
	@sudo $(RM) $(DESTDIR)/$(PREFIX)/bin/microca


dist: all
	@$(eval DIST_NAME = microca)
	@$(eval DIST_VERSION = $(shell cat bin/microca | grep "VERSION="  | cut -d"=" -f2))
	@$(RM) -r build/dist/
	@mkdir -p build/dist/$(DIST_NAME)-$(DIST_VERSION)/src/
	@cp -r $(SOURCE_EXTRA_LIST) build/dist/$(DIST_NAME)-$(DIST_VERSION)/
	@cp src/*.sh build/dist/$(DIST_NAME)-$(DIST_VERSION)/src/
	@tar -cz -C build/dist/ -f build/dist/$(DIST_NAME)-$(DIST_VERSION).tar.gz $(DIST_NAME)-$(DIST_VERSION)/
	@mkdir -p dist/
	@mv build/dist/$(DIST_NAME)-$(DIST_VERSION).tar.gz dist/
	@echo Output at dist/$(DIST_NAME)-$(DIST_VERSION).tar.gz


package: dist
	@command -v dpkg-deb >/dev/null 2>&1 || { echo >&2 "Package 'dpkg-deb' not installed!"; exit 1; }
	@$(eval DIST_NAME = microca)
	@$(eval DIST_VERSION = $(shell cat bin/microca | grep "VERSION="  | cut -d"=" -f2))
	@$(eval DEB_BUILD_ARCH = all)
	@$(eval PACKAGE_NAME = $(DIST_NAME)_$(DIST_VERSION)_$(DEB_BUILD_ARCH))
	@$(eval PACKAGE_DIR = /tmp/$(PACKAGE_NAME)/)
	-@$(RM) -r $(PACKAGE_DIR)/
	@mkdir $(PACKAGE_DIR)/
	@cp -r package/deb/DEBIAN $(PACKAGE_DIR)/
	@sed -i "s/MAJOR.MINOR/$(DIST_VERSION)/" $(PACKAGE_DIR)/DEBIAN/control
	@mkdir -p $(PACKAGE_DIR)/usr/share/doc/microca/
	@cp package/deb/copyright $(PACKAGE_DIR)/usr/share/doc/microca/copyright
	@cp CHANGES.md build/changelog
	@sed -i '/^$$/d' build/changelog
	@sed -i '/## Release Notes ##/d' build/changelog
	@sed -i '1{s/### \(.*\) \[.*/microca \(\1\) stable; urgency=low/}' build/changelog
	@sed -i '/###/,$$d' build/changelog
	@sed -i 's/\* \(.*\)/  \* \1/' build/changelog
	@echo >> build/changelog
	@echo ' -- Josip Medved <jmedved@jmedved.com>  $(shell date -R)' >> build/changelog
	@gzip -cn --best build/changelog > $(PACKAGE_DIR)/usr/share/doc/microca/changelog.gz
	@find $(PACKAGE_DIR)/ -type d -exec chmod 755 {} +
	@find $(PACKAGE_DIR)/ -type f -exec chmod 644 {} +
	@chmod 755 $(PACKAGE_DIR)/DEBIAN/p*inst
	@install -d $(PACKAGE_DIR)/usr/bin/
	@install bin/microca $(PACKAGE_DIR)/usr/bin/
	-@$(RM) /tmp/$(PACKAGE_NAME).deb
	@fakeroot dpkg-deb --build $(PACKAGE_DIR)/ > /dev/null
	@mv /tmp/$(PACKAGE_NAME).deb dist/
	@$(RM) -r $(PACKAGE_DIR)/
	-@lintian dist/$(PACKAGE_NAME).deb
	@echo Output at dist/$(PACKAGE_NAME).deb

zip: dist
	@command -v zip >/dev/null 2>&1 || { echo >&2 "Package 'zip' not installed!"; exit 1; }
	@$(eval DIST_NAME = microca)
	@$(eval DIST_VERSION = $(shell cat bin/microca | grep "VERSION="  | cut -d"=" -f2))
	@$(eval PACKAGE_NAME = $(DIST_NAME)_$(DIST_VERSION))
	@$(eval PACKAGE_DIR = /tmp/$(PACKAGE_NAME)/)
	-@$(RM) -r $(PACKAGE_DIR)/
	@mkdir $(PACKAGE_DIR)/
	@install src/microca.sh $(PACKAGE_DIR)/
	@cp README.md $(PACKAGE_DIR)/README.txt
	@cp LICENSE.md $(PACKAGE_DIR)/LICENSE.txt
	-@$(RM) /tmp/$(PACKAGE_NAME).zip
	@zip -jq /tmp/$(PACKAGE_NAME).zip $(PACKAGE_DIR)/*
	@mv /tmp/$(PACKAGE_NAME).zip dist/
	@$(RM) -r $(PACKAGE_DIR)/
	@echo Output at dist/$(PACKAGE_NAME).zip
