CWD := $(shell pwd)
BASEDIR := $(CWD)
PRINT_STATUS = export EC=$$?; cd $(CWD); if [ "$$EC" -eq "0" ]; then printf "SUCCESS!\n"; else exit $$EC; fi
VERSION=1.4.1
COMMIT := $(shell git rev-parse HEAD)
SHORTCOMMIT := $(shell echo $(COMMIT) | cut -c1-7)

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
	cp tendrl-api-$(VERSION).tar.gz $(RPMBUILD)/SOURCES; \
	cp tendrl-api-$(VERSION).tar.gz $(BASEDIR)/.
        # Cleaning the work directory
	rm -fr $(HOME)/$(BUILDS)

srpm:
	@echo "target: srpm"
	rm -fr $(BUILDS)
	mkdir -p $(DEPLOY)/latest
	mkdir -p $(RPMBUILD)/SPECS
	sed -e "s/@VERSION@/$(VERSION)/" tendrl-api.spec \
	        > $(RPMBUILD)/SPECS/tendrl-api.spec
	rpmbuild  --define "_sourcedir ." --define "_srcrpmdir ." --nodeps -bs tendrl-api.spec

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

update-release:
	sed -i tendrl-api.spec \
	  -e "/^Release:/cRelease: $(shell date +"%Y%m%dT%H%M%S").$(SHORTCOMMIT)"

snapshot: update-release srpm
