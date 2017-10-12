%global selinuxtype targeted
%global moduletype  services

# todo relable should be enhanced later to specific things
%global relabel_files() %{_sbindir}/restorecon -Rv /

Name: tendrl-api
Version: 1.5.3
Release: 1%{?dist}
Summary: Collection of tendrl api extensions
Group: Development/Languages
License: LGPLv2+
URL: https://github.com/Tendrl/api
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch

BuildRequires: ruby
BuildRequires: systemd-units

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
Requires: rubygem-tzinfo >= 1.2.2
Requires: rubygem-etcd
Requires: rubygem-rack-protection >= 1.5.3
Requires: rubygem-activesupport >= 4.2.6
Requires: rubygem-sinatra >= 1.4.5
Requires: tendrl-node-agent

%description
Collection of tendrl api.

%package -n tendrl-server-selinux
License: GPLv2
Group: System Environment/Base
Summary: SELinux Policies for Tendrl Server
BuildArch: noarch
Requires(post): selinux-policy-base, selinux-policy-targeted, policycoreutils, policycoreutils-python libselinux-utils
BuildRequires: selinux-policy selinux-policy-devel

%description -n tendrl-server-selinux
SELinux Policies for Tendrl Server

%package -n tendrl-grafana-selinux
License: GPLv2
Group: System Environment/Base
Summary: SELinux Policies for Tendrl Grafana
BuildArch: noarch
Requires(post): selinux-policy-base, selinux-policy-targeted, policycoreutils, policycoreutils-python libselinux-utils
BuildRequires: selinux-policy selinux-policy-devel

%description -n tendrl-grafana-selinux
SELinux Policies for Tendrl Grafana

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%package -n carbon-selinux
License: GPLv2
Group: System Environment/Base
Summary: SELinux Policies for Carbon
BuildArch: noarch
Requires(post): selinux-policy-base >= %{selinux_policyver}, selinux-policy-targeted >= %{selinux_policyver}, policycoreutils, policycoreutils-python libselinux-utils
BuildRequires: selinux-policy selinux-policy-devel

%description -n carbon-selinux
SELinux Policies for Carbon

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

%build
make bzip-selinux-policy

%install
install -m  0755  --directory $RPM_BUILD_ROOT%{_var}/log/tendrl/api
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/app/controllers
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/app/forms
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/app/presenters
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/app/models
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/lib/tendrl/errors
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/doc/tendrl/config
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/public
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/.deploy
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/log
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/tmp
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/config
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/config/puma
install -dm 0755 --directory $RPM_BUILD_ROOT%{_datadir}/%{name}/config/initializers
install -Dm 0644 Rakefile *.ru Gemfile* $RPM_BUILD_ROOT%{_datadir}/%{name}
install -Dm 0644 app/controllers/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/app/controllers/
install -Dm 0644 app/forms/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/app/forms/
install -Dm 0644 app/presenters/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/app/presenters/
install -Dm 0644 app/models/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/app/models/
install -Dm 0644 lib/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/lib/
install -Dm 0644 lib/tendrl/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/lib/tendrl/
install -Dm 0644 lib/tendrl/errors/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/lib/tendrl/errors/
install -Dm 0644 tendrl-api.service $RPM_BUILD_ROOT%{_unitdir}/tendrl-api.service
install -Dm 0640 config/etcd.sample.yml $RPM_BUILD_ROOT%{_sysconfdir}/tendrl/etcd.yml
install -Dm 0644 README.adoc Rakefile $RPM_BUILD_ROOT%{_datadir}/doc/tendrl
install -Dm 0644 config/apache.vhost-ssl.sample $RPM_BUILD_ROOT%{_sysconfdir}/httpd/conf.d/tendrl-ssl.conf.sample
install -Dm 0644 config/apache.vhost.sample $RPM_BUILD_ROOT%{_sysconfdir}/httpd/conf.d/tendrl.conf
install -Dm 0644 config/puma/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/config/puma/
install -Dm 0644 config/initializers/*.rb $RPM_BUILD_ROOT%{_datadir}/%{name}/config/initializers/

# Install SELinux interfaces and policy modules
install -d %{buildroot}%{_datadir}/selinux/packages

# tendrl
install -m 0644 selinux/tendrl.pp.bz2 \
	%{buildroot}%{_datadir}/selinux/packages

# carbon
install -m 0644 selinux/carbon.pp.bz2 \
        %{buildroot}%{_datadir}/selinux/packages

# grafana
install -m 0644 selinux/grafana.pp.bz2 \
        %{buildroot}%{_datadir}/selinux/packages


%post -n tendrl-server-selinux
%selinux_modules_install -s %{selinuxtype} %{_datadir}/selinux/packages/tendrl.pp.bz2
if %{_sbindir}/selinuxenabled ; then
    %{_sbindir}/load_policy
    %relabel_files
fi

%post -n carbon-selinux
%selinux_modules_install -s %{selinuxtype} %{_datadir}/selinux/packages/carbon.pp.bz2
if %{_sbindir}/selinuxenabled ; then
    %{_sbindir}/load_policy
    %relabel_files
fi

%post -n tendrl-grafana-selinux
%selinux_modules_install -s %{selinuxtype} %{_datadir}/selinux/packages/grafana.pp.bz2
if %{_sbindir}/selinuxenabled ; then
    %{_sbindir}/load_policy
    %relabel_files
fi

%post httpd
setsebool -P httpd_can_network_connect 1
systemctl enable tendrl-api

%postun -n tendrl-server-selinux
if [ $1 -eq 0 ]; then
    %selinux_modules_uninstall -s %{selinuxtype} tendrl &> /dev/null || :
    if %{_sbindir}/selinuxenabled ; then
	%{_sbindir}/load_policy
	%relabel_files
    fi
fi

%postun -n carbon-selinux
if [ $1 -eq 0 ]; then
    %selinux_modules_uninstall -s %{selinuxtype} carbon &> /dev/null || :
    if %{_sbindir}/selinuxenabled ; then
        %{_sbindir}/load_policy
        %carbon_relabel_files
    fi
fi

%postun -n tendrl-grafana-selinux
if [ $1 -eq 0 ]; then
        %selinux_modules_uninstall -s %{selinuxtype} grafana &> /dev/null || :
    if %{_sbindir}/selinuxenabled ; then
        %{_sbindir}/load_policy
        %carbon_relabel_files
    fi
fi

%files -n tendrl-server-selinux
%defattr(-,root,root,0755)
%attr(0644,root,root) %{_datadir}/selinux/packages/tendrl.pp.bz2

%files -n carbon-selinux
%defattr(-,root,root,0755)
%attr(0644,root,root) %{_datadir}/selinux/packages/carbon.pp.bz2

%files -n tendrl-grafana-selinux
%defattr(-,root,root,0755)
%attr(0644,root,root) %{_datadir}/selinux/packages/grafana.pp.bz2

%files
%license LICENSE
%dir %{_var}/log/tendrl/api
%dir %{_sysconfdir}/tendrl
%{_datadir}/%{name}/
%{_unitdir}/tendrl-api.service
%config(noreplace) %{_sysconfdir}/tendrl/etcd.yml

%files doc
%dir %{_datadir}/doc/tendrl/config
%doc %{_datadir}/doc/tendrl/README.adoc
%{_datadir}/doc/tendrl/config/
%{_datadir}/doc/tendrl/Rakefile

%files httpd
%config(noreplace) %{_sysconfdir}/httpd/conf.d/tendrl-ssl.conf.sample
%config(noreplace) %{_sysconfdir}/httpd/conf.d/tendrl.conf

%changelog
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
