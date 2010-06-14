PKGNAME		:= puppet-module-git
SPECFILE	:= $(PKGNAME).spec
VERSION		:= $(shell rpm -q --qf "%{VERSION}\n" --specfile $(SPECFILE)| head -1)
RELEASE		:= $(shell rpm -q --qf "%{RELEASE}\n" --specfile $(SPECFILE)| head -1)

clean:
	@rm -rf $(PKGNAME)-$(VERSION)/
	@rm -rf $(PKGNAME)-$(VERSION).tar.gz

test: clean
	@puppet --noop --parseonly manifests/init.pp
	@echo All OK

archive: test
	@rm -rf $(PKGNAME)-$(VERSION).tar.gz
	@rm -rf /tmp/$(PKGNAME)-$(VERSION) /tmp/$(PKGNAME)
	@dir=$$PWD; cd /tmp; cp -a $$dir $(PKGNAME)
	@mv /tmp/$(PKGNAME) /tmp/$(PKGNAME)-$(VERSION)
	@dir=$$PWD; cd /tmp; tar --exclude .git --gzip -cvf $$dir/$(PKGNAME)-$(VERSION).tar.gz $(PKGNAME)-$(VERSION)
	@rm -rf /tmp/$(PKGNAME)-$(VERSION)
	@echo "The archive is in $(PKGNAME)-$(VERSION).tar.gz"

bumpspec: test
	@rpmdev-bumpspec $(SPECFILE)

rpm: archive
	@rpmbuild -ta $(PKGNAME)-$(VERSION).tar.gz

srpm: archive
	@rpmbuild -ts $(PKGNAME)-$(VERSION).tar.gz

tag:
	@git tag -m "$(PKGNAME)-$(VERSION)-$(RELEASE)" $(PKGNAME)-$(VERSION)-$(RELEASE)

release: tag rpm
	@scp $(PKGNAME)-$(VERSION).tar.gz puppetmanaged.org:/data/www/puppetmanaged.org/www/public_html/releases/.
	@scp ~/rpmbuild/SRPMS/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/f9/SRPMS/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/i386/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/ppc64/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/ppc/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/x86_64/
	@scp ~/rpmbuild/SRPMS/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/f10/SRPMS/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/i386/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/ppc64/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/ppc/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/x86_64/
	@scp ~/rpmbuild/SRPMS/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/f11/SRPMS/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/i386/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/ppc64/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/ppc/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/x86_64/
	@scp ~/rpmbuild/SRPMS/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/el4/SRPMS/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/i386/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/ppc64/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/ppc/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/x86_64/
	@scp ~/rpmbuild/SRPMS/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/el5/SRPMS/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/i386/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/ppc64/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/ppc/
	@scp ~/rpmbuild/RPMS/noarch/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/x86_64/

release-mock: tag rpm
	@mock -v -r fedora-rawhide-i386 rebuild ~/rpmbuild/SRPMS/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/f9/SRPMS/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/i386/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/ppc64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/ppc/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f9/x86_64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/f10/SRPMS/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/i386/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/ppc64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/ppc/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f10/x86_64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/f11/SRPMS/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/i386/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/ppc64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/ppc/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/f11/x86_64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/el4/SRPMS/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/i386/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/ppc64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/ppc/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el4/x86_64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).src.rpm elwood:/data/os/repos/custom/el5/SRPMS/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/i386/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/ppc64/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/ppc/
	@scp /var/lib/mock/fedora-rawhide-i386/result/$(PKGNAME)-$(VERSION)-$(RELEASE).noarch.rpm elwood:/data/os/repos/custom/el5/x86_64/

install:
	mkdir -p $(DESTDIR)/var/lib/puppetmanaged.org/modules/git
	cp -r files $(DESTDIR)/var/lib/puppetmanaged.org/modules/git/
	cp -r manifests $(DESTDIR)/var/lib/puppetmanaged.org/modules/git/
	cp -r templates $(DESTDIR)/var/lib/puppetmanaged.org/modules/git/
