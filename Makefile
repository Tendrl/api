NAME      := tendrl-api
VERSION   := 1.5.2
RELEASE   := 1
COMMIT := $(shell git rev-parse HEAD)
SHORTCOMMIT := $(shell echo $(COMMIT) | cut -c1-7)

all: srpm

dist:
	mkdir -p $(NAME)-$(VERSION)
	cp -r app config docs lib public spec selinux $(NAME)-$(VERSION)/
	cp config.ru Gemfile* Makefile Rakefile README* tendrl-api.* $(NAME)-$(VERSION)/
	tar -zcf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)
	rm -rf $(NAME)-$(VERSION)

bzip-selinux-policy:
	@cd selinux; \
	rm -f *.pp.bz2 tmp; \
	make -f /usr/share/selinux/devel/Makefile; \
	bzip2 -9 tendrl.pp; \
        bzip2 -9 carbon.pp; \
        bzip2 -9 grafana.pp

clean:
	rm -f $(NAME)-$(VERSION).tar.gz
	rm -f $(NAME)-$(VERSION)*.rpm
	rm -f *.log

srpm: dist
	fedpkg --dist epel7 srpm

rpm: srpm
	mock -r epel-7-x86_64 rebuild $(NAME)-$(VERSION)-$(RELEASE).el7.src.rpm --resultdir=. --define "dist .el7"

update-release:
	sed -i $(NAME).spec \
	  -e "/^Release:/cRelease: $(shell date +"%Y%m%dT%H%M%S").$(SHORTCOMMIT)"

snapshot: update-release srpm

.PHONY: dist rpm srpm update-release snapshot
