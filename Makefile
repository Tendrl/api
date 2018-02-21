NAME      := tendrl-api
VERSION   := 1.6.0
RELEASE   := 1
COMMIT := $(shell git rev-parse HEAD)
SHORTCOMMIT := $(shell echo $(COMMIT) | cut -c1-7)
BRANCH := $(shell git symbolic-ref --short HEAD)

all: srpm

dist:
	mkdir -p $(NAME)-$(VERSION)
	cp -r app config docs firewalld lib public spec $(NAME)-$(VERSION)/
	cp config.ru LICENSE Gemfile* Makefile Rakefile README* tendrl-api.* $(NAME)-$(VERSION)/
	tar -zcf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)
	rm -rf $(NAME)-$(VERSION)

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

update-release-pr:
	sed -i $(NAME).spec \
	  -e "/^Release:/cRelease: $(shell date +"%Y%m%dT%H%M%S").$(SHORTCOMMIT).$(BRANCH)"

snapshot: update-release srpm

snapshot-pr: update-release-pr srpm

.PHONY: dist rpm srpm update-release update-release-pr snapshot snapshot-pr
