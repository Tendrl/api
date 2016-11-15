Name: tendrl-api
Version: 0.0.1
Release: 1%{?dist}
Summary: Collection of tendrl api extensions
Group: Development/Languages
License: LGPLv2+
URL: https://github.com/Tendrl/tendrl-api
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch

BuildRequires: ruby

Requires: httpd
Requires: ruby
Requires: rubygem-sinatra
Requires: rubygem-sinatra-contrib
Requires: rubygem-activesupport
Requires: rubygem-etcd
Requires: rubygem-puma
Requires: rubygem-sinatra-cross_origin

%description
Collection of tendrl api.

%prep
%setup

%install
install -m 755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}
install -m 755 --directory config $RPM_BUILD_ROOT%{_datadir}/%{name}/config
install -m 755 --directory lib $RPM_BUILD_ROOT%{_datadir}/%{name}/lib
install -Dm 0644 *.ru *.rb $RPM_BUILD_ROOT%{_datadir}/%{name}
install -Dm 0644 config/etcd.sample.yml $RPM_BUILD_ROOT%{_sysconfdir}/tendrl/api/config/etcd.yml
install -Dm 0644 config/apache.vhost.sample $RPM_BUILD_ROOT%{_sysconfdir}/httpd/conf.d/tendrl.conf
install -Dm 0644 tendrl-apid.service $RPM_BUILD_ROOT%{_unitdir}/tendrl-apid.service

%post
setsebool -P httpd_can_network_connect 1
/bin/systemctl  start httpd.service >/dev/null 2>&1 || :
%systemd_post tendrl-apid.service

%preun
%systemd_preun tendrl-apid.service

%postun
%systemd_postun_with_restart tendrl-apid.service

%files
%{_datadir}/%{name}/*.ru
%{_datadir}/%{name}/*.rb
%dir %{_datadir}/%{name}
%dir %{_datadir}/%{name}/config
%dir %{_datadir}/%{name}/lib
%{_sysconfdir}/tendrl/api/config/etcd.yml
%{_sysconfdir}/httpd/conf.d/tendrl.conf
%{_unitdir}/tendrl-apid.service

%changelog
* Fri Nov 14 2016 Tim <tim.gluster@gmail.com> - 0.0.1-1
- Initial package
