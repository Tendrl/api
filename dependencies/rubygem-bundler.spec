# Generated from bundler-1.13.6.gem by gem2rpm -*- rpm-spec -*-
%global gem_name bundler

Name: rubygem-%{gem_name}
Version: 1.13.6
Release: 1%{?dist}
Summary: The best way to manage your application's dependencies
Group: Development/Languages
License: MIT
URL: http://bundler.io
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel >= 1.3.6
BuildRequires: ruby >= 1.8.7
# BuildRequires: rubygem(automatiek) => 0.1.0
# BuildRequires: rubygem(automatiek) < 0.2
# BuildRequires: rubygem(mustache) = 0.99.6
# BuildRequires: rubygem(rdiscount) => 2.2
# BuildRequires: rubygem(rdiscount) < 3
# BuildRequires: rubygem(ronn) => 0.7.3
# BuildRequires: rubygem(ronn) < 0.8
# BuildRequires: rubygem(rspec) => 3.5
# BuildRequires: rubygem(rspec) < 4
BuildArch: noarch

%description
Bundler manages an application's dependencies through its entire life, across
many machines, systematically and repeatably.


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


mkdir -p %{buildroot}%{_bindir}
cp -pa .%{_bindir}/* \
        %{buildroot}%{_bindir}/

find %{buildroot}%{gem_instdir}/bin -type f | xargs chmod a+x
find %{buildroot}%{gem_instdir}/lib/bundler/templates/newgem/bin -type f | xargs chmod 755
chmod 755 %{buildroot}%{gem_instdir}/lib/bundler/templates/Executable*

# Man pages are used by Bundler internally, do not remove them!
mkdir -p %{buildroot}%{_mandir}/man5
cp -a %{buildroot}%{gem_libdir}/bundler/man/gemfile.5 %{buildroot}%{_mandir}/man5
mkdir -p %{buildroot}%{_mandir}/man1
for i in bundle bundle-config bundle-exec bundle-install bundle-package bundle-platform bundle-update
do
    cp -a %{buildroot}%{gem_libdir}/bundler/man/$i %{buildroot}%{_mandir}/man1/`echo $i.1`
done

# Run the test suite
%check
pushd .%{gem_instdir}

popd

%files
%dir %{gem_instdir}
%{_bindir}/bundle
%{_bindir}/bundler
%{gem_instdir}/.codeclimate.yml
%exclude %{gem_instdir}/.gitignore
%{gem_instdir}/.rspec
%exclude %{gem_instdir}/.rubocop.yml
%{gem_instdir}/.rubocop_todo.yml
%exclude %{gem_instdir}/.travis.yml
%{gem_instdir}/CODE_OF_CONDUCT.md
%{gem_instdir}/DEVELOPMENT.md
%{gem_instdir}/ISSUES.md
%license %{gem_instdir}/LICENSE.md
%{gem_instdir}/bin
%{gem_instdir}/exe
%{gem_libdir}
%{gem_instdir}/man
%exclude %{gem_cache}
%{gem_spec}
%doc %{_mandir}/man1/*
%doc %{_mandir}/man5/*

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/CHANGELOG.md
%doc %{gem_instdir}/CONTRIBUTING.md
%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile
%{gem_instdir}/bundler.gemspec

%changelog
* Mon Nov 21 2016 Tim <tim.gluster@gmail.com> - 1.13.6-1
- Initial package
