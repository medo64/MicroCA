ifeq ($(PREFIX),)
    PREFIX := /usr/local/
endif


SOURCE_EXTRA_LIST := LICENSE.md Makefile README.md


.PHONY: all clean distclean install uninstall dist


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
