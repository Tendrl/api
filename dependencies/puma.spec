# Generated from puma-3.6.0.gem by gem2rpm -*- rpm-spec -*-
%global gem_name puma

Name: rubygem-%{gem_name}
Version: 3.6.0
Release: 1%{?dist}
Summary: Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications
Group: Development/Languages
License: BSD-3-Clause
URL: http://puma.io
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby-devel >= 1.8.7

# BuildRequires: rubygem(rack) >= 1.1
# BuildRequires: rubygem(rack) < 2.0
# BuildRequires: rubygem(rake-compiler) => 0.8
# BuildRequires: rubygem(rake-compiler) < 1
# BuildRequires: rubygem(hoe) => 3.15
# BuildRequires: rubygem(hoe) < 4

%description
Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for
Ruby/Rack applications. Puma is intended for use in both development and
production environments. In order to get the best throughput, it is highly
recommended that you use a  Ruby implementation with real threads like
Rubinius or JRuby.


%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
gem unpack %{SOURCE0}

%setup -q -D -T -n  %{gem_name}-%{version}
bundle install --path vendor/bundle --binstubs vendor/bin

gem spec %{SOURCE0} -l --ruby > %{gem_name}.gemspec

%build
# Create the gem as gem install only works on a gem file
gem build %{gem_name}.gemspec

# %%gem_install compiles any C extensions and installs the gem into ./%%gem_dir
# by default, so that we can move it into the buildroot in %%install
%gem_install

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{gem_extdir_mri}/puma
cp -a .%{gem_extdir_mri}/gem.build_complete %{buildroot}%{gem_extdir_mri}/ || :
cp -a .%{gem_extdir_mri}/puma/*.so %{buildroot}%{gem_extdir_mri}/puma  || :
install -Dm 0755 vendor/bin/puma %{buildroot}%{gem_extdir_mri}/puma/

#mkdir -p %{buildroot}%{gem_extdir_mri}
cp -a .%{gem_extdir_mri}/{gem.build_complete,*.so} %{buildroot}%{gem_extdir_mri}/  || :

# Prevent dangling symlink in -debuginfo (rhbz#878863).
rm -rf %{buildroot}%{gem_instdir}/ext/

mkdir -p %{buildroot}%{_bindir}
cp -pa .%{_bindir}/* \
        %{buildroot}%{_bindir}/

find %{buildroot}%{gem_instdir}/bin -type f | xargs chmod a+x

# Run the test suite
%check
pushd .%{gem_instdir}

popd

%files
%dir %{gem_instdir}
%{_bindir}/puma
%{_bindir}/pumactl
%{gem_extdir_mri}
%{gem_instdir}/DEPLOYMENT.md
%license %{gem_instdir}/LICENSE
%{gem_instdir}/Manifest.txt
%{gem_instdir}/bin
%{gem_libdir}
%{gem_instdir}/tools
%exclude %{gem_cache}
%{gem_spec}
%{buildroot}/etc/

%files doc
%doc %{gem_docdir}
%{gem_instdir}/Gemfile
%doc %{gem_instdir}/History.txt
%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile
%doc %{gem_instdir}/docs
%{gem_instdir}/puma.gemspec

%changelog
* Fri Nov 18 2016 Tim <tim.gluster@gmail.com> - 3.6.0-2
- Fix .so file path
- Fix ext not found error

* Wed Nov 16 2016 Tim <tim.gluster@gmail.com> - 3.6.0-1
- Initial package
