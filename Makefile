CWD := $(shell pwd)
BASEDIR := $(CWD)
PRINT_STATUS = export EC=$$?; cd $(CWD); if [ "$$EC" -eq "0" ]; then printf "SUCCESS!\n"; else exit $$EC; fi
VERSION=1.4.1

BUILDS    := .build
DEPLOY    := $(BUILDS)/deploy
TARDIR    := tendrl-api-$(VERSION)
RPMBUILD  := $(HOME)/rpmbuild


dist:
	rm -fr $(HOME)/$(BUILDS)
	mkdir -p $(HOME)/$(BUILDS) $(RPMBUILD)/SOURCES
	cp -fr $(BASEDIR) $(HOME)/$(BUILDS)/$(TARDIR)
	cd $(HOME)/$(BUILDS); \
	tar --exclude-vcs --exclude=.* -zcf tendrl-api-$(VERSION).tar.gz $(TARDIR); \
	cp tendrl-api-$(VERSION).tar.gz $(RPMBUILD)/SOURCES
        # Cleaning the work directory
	rm -fr $(HOME)/$(BUILDS)


srpm:
	rpmbuild -bs tendrl-api.spec
	cp $(RPMBUILD)/SRPMS/tendrl-api-$(VERSION)*src.rpm .

rpm:
	@echo "target: rpm"
	@echo  "  ...building rpm $(V_ARCH)..."
	rm -fr $(BUILDS)
	mkdir -p $(DEPLOY)/latest
	mkdir -p $(RPMBUILD)/SPECS
	sed -e "s/@VERSION@/$(VERSION)/" tendrl-api.spec \
	        > $(RPMBUILD)/SPECS/tendrl-api.spec
	rpmbuild -ba $(RPMBUILD)/SPECS/tendrl-api.spec
	$(PRINT_STATUS); \
	if [ "$$EC" -eq "0" ]; then \
		FILE=$$(readlink -f $$(find $(RPMBUILD)/RPMS -name tendrl-api*.rpm)); \
		cp -f $$FILE $(DEPLOY)/latest/; \
		printf "\nThe tendrl-api RPMs are located at:\n\n"; \
		printf "   $(DEPLOY)/latest\n\n\n\n"; \
	fi
