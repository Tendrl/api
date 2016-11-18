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
BuildRequires: systemd-units

Requires: ruby >= 2.0.0
Requires: rubygem-sinatra
Requires: rubygem-activesupport
Requires: rubygem-etcd
Requires: rubygem-puma

%description
Collection of tendrl api.

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%package httpd
Summary: Tendrl api httpd
Requires: %{name} = %{version}-%{release}
BuildArch: noarch
Requires: httpd

%description httpd
Tendrl API httpd configuration.

%prep
%setup

%install
install -m 755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}
install -m 755 --directory config $RPM_BUILD_ROOT%{_datadir}/%{name}
install -m 755 --directory lib $RPM_BUILD_ROOT%{_datadir}/%{name}/lib
install -m 755 --directory $RPM_BUILD_ROOT%{_datadir}/doc/tendrl/config
install -Dm 0644 *.ru *.rb $RPM_BUILD_ROOT%{_datadir}/%{name}
install -Dm 0644 tendrl-apid.service $RPM_BUILD_ROOT%{_unitdir}/tendrl-apid.service
install -Dm 0644 config/etcd.sample.yml $RPM_BUILD_ROOT%{_sysconfdir}/tendrl/etcd.yml
install -Dm 0644 README.adoc Rakefile $RPM_BUILD_ROOT%{_datadir}/doc/tendrl
install -Dm 0644 config/apache.vhost.sample $RPM_BUILD_ROOT%{_sysconfdir}/httpd/conf.d/tendrl.conf
install -Dm 0644 config/*.sample $RPM_BUILD_ROOT%{_datadir}/doc/tendrl/config/.

%post httpd
setsebool -P httpd_can_network_connect 1

%files
%dir %{_datadir}/%{name}
%dir %{_datadir}/%{name}/lib
%dir %{_sysconfdir}/tendrl
%{_datadir}/%{name}/*.ru
%{_datadir}/%{name}/*.rb
%{_unitdir}/tendrl-apid.service
%{_sysconfdir}/tendrl/etcd.yml

%files doc
%dir %{_datadir}/doc/tendrl/config
%doc %{_datadir}/doc/tendrl/README.adoc
%{_datadir}/doc/tendrl/config/
%{_datadir}/doc/tendrl/Rakefile

%files httpd
%{_sysconfdir}/httpd/conf.d/tendrl.conf

%changelog
* Wed Nov 16 2016 Tim <tim.gluster@gmail.com> - 0.0.1-1
- Initial package
