%global name tendrl-api
%global app_group %{name}
%global app_user %{name}
%global install_dir %{_datadir}/%{name}
%global config_dir %{_sysconfdir}/tendrl
%global doc_dir %{_docdir}/%{name}
%global log_dir %{_var}/log/tendrl/api
%global tmp_dir %{_var}/tmp
%global config_file %{config_dir}/etcd.yml

Name: %{name}
Version: 1.6.3
Release: 7%{?dist}
Summary: Collection of tendrl api extensions
Group: Development/Languages
License: LGPLv2+
URL: https://github.com/Tendrl/api
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch

BuildRequires: ruby
BuildRequires: systemd-units
BuildRequires: systemd

Requires: ruby >= 2.0.0
Requires: rubygem-activemodel >= 4.2.6
Requires: rubygem-bcrypt >= 3.1.10
Requires: rubygem-i18n >= 0.7.0
Requires: rubygem-json
Requires: rubygem-minitest >= 5.9.1
Requires: rubygem-thread_safe >= 0.3.5
Requires: rubygem-mixlib-log >= 1.7.1
Requires: rubygem-puma >= 3.6.0
Requires: rubygem-rake >= 0.9.6
Requires: rubygem-rack >= 1.6.4
Requires: rubygem-tilt >= 1.4.1
Requires: rubygem-bundler >= 1.13.6
Requires: rubygem-builder >= 3.1.0
Requires: rubygem-tzinfo >= 1.2.2
Requires: rubygem-etcd
Requires: rubygem-rack-protection >= 1.5.3
Requires: rubygem-activesupport >= 4.2.6
Requires: rubygem-sinatra >= 1.4.5
Requires: tendrl-node-agent

%description
Collection of tendrl api.

%package httpd
Summary: Tendrl api httpd
Requires: %{name} = %{version}-%{release}
BuildArch: noarch
Requires: httpd

%description httpd
Tendrl API httpd configuration.

%prep
%setup

%build

%install
install -m 0755 --directory $RPM_BUILD_ROOT%{log_dir}
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/app/controllers
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/app/forms
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/app/presenters
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/app/models
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/lib/tendrl/errors
install -m 0755 --directory $RPM_BUILD_ROOT%{doc_dir}/config
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/public
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/config
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/config/puma
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/config/initializers
install -m 0755 --directory $RPM_BUILD_ROOT%{install_dir}/.deploy
install -Dm 0644 Rakefile *.ru Gemfile* $RPM_BUILD_ROOT%{install_dir}
install -Dm 0644 app/controllers/*.rb $RPM_BUILD_ROOT%{install_dir}/app/controllers/
install -Dm 0644 app/forms/*.rb $RPM_BUILD_ROOT%{install_dir}/app/forms/
install -Dm 0644 app/presenters/*.rb $RPM_BUILD_ROOT%{install_dir}/app/presenters/
install -Dm 0644 app/models/*.rb $RPM_BUILD_ROOT%{install_dir}/app/models/
install -Dm 0644 lib/*.rb $RPM_BUILD_ROOT%{install_dir}/lib/
install -Dm 0644 lib/tendrl/*.rb $RPM_BUILD_ROOT%{install_dir}/lib/tendrl/
install -Dm 0644 lib/tendrl/errors/*.rb $RPM_BUILD_ROOT%{install_dir}/lib/tendrl/errors/
install -Dm 0644 tendrl-api.service $RPM_BUILD_ROOT%{_unitdir}/tendrl-api.service
install -Dm 0640 config/etcd.sample.yml $RPM_BUILD_ROOT%{config_file}
install -Dm 0644 README.adoc Rakefile $RPM_BUILD_ROOT%{doc_dir}
install -Dm 0644 config/apache.vhost-ssl.sample $RPM_BUILD_ROOT%{_sysconfdir}/httpd/conf.d/tendrl-ssl.conf.sample
install -Dm 0644 config/apache.vhost.sample $RPM_BUILD_ROOT%{_sysconfdir}/httpd/conf.d/tendrl.conf
install -Dm 0644 config/puma/*.rb $RPM_BUILD_ROOT%{install_dir}/config/puma/
install -Dm 0644 config/initializers/*.rb $RPM_BUILD_ROOT%{install_dir}/config/initializers/
install -Dm 0644 firewalld/tendrl-api.xml $RPM_BUILD_ROOT%{_prefix}/lib/firewalld/services/tendrl-api.xml
install -Dm 0644 config/tendrl-api_logrotate.conf $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/tendrl-api_logrotate.conf

# Symlink writable directories onto /var
ln -s %{log_dir} $RPM_BUILD_ROOT%{install_dir}/log
ln -s %{tmp_dir} $RPM_BUILD_ROOT%{install_dir}/tmp

%pre
getent group %{app_group} > /dev/null || \
    groupadd -r %{app_group}
getent passwd %{app_user} > /dev/null || \
    useradd -r -d %{install_dir} -M -g %{app_group} \
	    -s /sbin/nologin %{app_user}

%post httpd
setsebool -P httpd_can_network_connect 1
systemctl enable tendrl-api >/dev/null 2>&1 || :

%post
%systemd_post tendrl-api.service

%preun
%systemd_preun tendrl-api.service

%postun
%systemd_postun_with_restart tendrl-api.service

%files
%license LICENSE
%dir %attr(0755, %{app_user}, %{app_group}) %{log_dir}
%dir %{config_dir}
%{install_dir}/
%{doc_dir}/
%{_unitdir}/tendrl-api.service
%config(noreplace) %{_sysconfdir}/logrotate.d/tendrl-api_logrotate.conf
%config(noreplace) %attr(0640, root, %{app_group}) %{config_file}
%config(noreplace) %{_prefix}/lib/firewalld/services/tendrl-api.xml

%files httpd
%config(noreplace) %{_sysconfdir}/httpd/conf.d/tendrl-ssl.conf.sample
%config(noreplace) %{_sysconfdir}/httpd/conf.d/tendrl.conf

%changelog
* Fri Jan 18 2019 Gowtham Shanmugasundaram <gshanmug@redhat.com> - 1.6.3-8
- Log rotation for tendrl log files

* Fri Jul 27 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.3-7
- Bugfix for recursion when non-json 'data' attr is present

* Wed Jul 04 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.3-6
- Restrict username length to 20 chars

* Wed Jul 04 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.3-5
- Add job ID to job data for node-agent

* Tue May 29 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.3-4
- Allow passing job flags to unmanage API

* Fri May 04 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.3-3
- Bugfixes for user management

* Wed Apr 25 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.3-2
- Bugfix for volume-bricks API

* Wed Apr 18 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.3-1
- https://github.com/Tendrl/api/milestone/5
- Object marshalling/unmarshalling to/from etcd
- Allow short_name as an attribute for cluster

* Thu Mar 22 2018 Shirshendu Mukherjee <smukherj@redhat.com> - 1.6.2-1
- https://github.com/Tendrl/api/milestone/4
- Bugfixes
- API call for expand cluster

* Wed Mar 07 2018 Rohan Kanade <rkanade@redhat.com> - 1.6.1-1
- Bugfixes (https://github.com/Tendrl/api/milestone/3)

* Sat Feb 17 2018 Rohan Kanade <rkanade@redhat.com> - 1.6.0-1
- API to un-manage clusters managed by Tendrl

* Fri Feb 02 2018 Rohan Kanade <rkanade@redhat.com> - 1.5.5-1
- Adds brick_count per node to /clusters/:cluster_id/nodes
- Adds api /clusters/:cluster_id/notifications
- Adds api /cluster/:cluster_id/jobs
- Adds volume alert count to /clusters/:cluster_id

* Thu Nov 30 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.4-4
- Bugfixes

* Mon Nov 27 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.4-3
- Supress service enable message during package update

* Fri Nov 10 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.4-2
- Bugfixes tendrl-api v1.5.4

* Thu Nov 02 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.4-1
- Release tendrl-api v1.5.4

* Fri Oct 13 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.3-2
- Release tendrl-api v1.5.3

* Thu Oct 12 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.3-1
- Release tendrl-api v1.5.3

* Fri Sep 15 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.2-1
- Release tendrl-api v1.5.2

* Fri Aug 25 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.1-1
- Release tendrl-api v1.5.1

* Fri Aug 04 2017 Rohan Kanade <rkanade@redhat.com> - 1.5.0-1
- Release tendrl-api v1.5.0

* Mon Jun 19 2017 Rohan Kanade <rkanade@redhat.com> - 1.4.2-1
- Release tendrl-api v1.4.2

* Thu Jun 08 2017 Anup Nivargi <anivargi@redhat.com> - 1.4.1-1
- Release tendrl-api v1.4.1

* Fri Jun 02 2017 Rohan Kanade <rkanade@redhat.com> - 1.4.0-1
- Release tendrl-api v1.4.0

* Tue Apr 18 2017 Anup Nivargi <anivargi@redhat.com> - 1.2-3
- Version bump to the 1.2.3 release.

* Wed Apr 05 2017 Anup Nivargi <anivargi@redhat.com> - 1.2-2
- Version bump to the 1.2.2 release.

* Fri Jan 27 2017 Mrugesh Karnik <mkarnik@redhat.com> - 1.2-1
- Version bump to the 1.2 release.

* Wed Nov 16 2016 Tim <tim.gluster@gmail.com> - 0.0.1-1
- Initial package
