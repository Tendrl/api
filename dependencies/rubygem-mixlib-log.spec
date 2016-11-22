# Generated from mixlib-log-1.7.1.gem by gem2rpm -*- rpm-spec -*-
%global gem_name mixlib-log

Name: rubygem-%{gem_name}
Version: 1.7.1
Release: 1%{?dist}
Summary: A gem that provides a simple mixin for log functionality
Group: Development/Languages
License: Apache-2.0
URL: https://www.chef.io
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
# BuildRequires: rubygem(rspec) => 3.4
# BuildRequires: rubygem(rspec) < 4
# BuildRequires: rubygem(chefstyle) => 0.3
# BuildRequires: rubygem(chefstyle) < 1
# BuildRequires: rubygem(cucumber)
# BuildRequires: rubygem(github_changelog_generator) = 1.11.3
BuildArch: noarch

%description
A gem that provides a simple mixin for log functionality.


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




# Run the test suite
%check
pushd .%{gem_instdir}

popd

%files
%dir %{gem_instdir}
%exclude %{gem_instdir}/.gemtest
%license %{gem_instdir}/LICENSE
%{gem_instdir}/NOTICE
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%{gem_instdir}/Gemfile
%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile
%{gem_instdir}/mixlib-log.gemspec
%{gem_instdir}/spec

%changelog
* Mon Nov 21 2016 Tim <tim.gluster@gmail.com> - 1.7.1-1
- Initial package
