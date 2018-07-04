# Generated from jwt-1.5.6.gem by gem2rpm -*- rpm-spec -*-
%global gem_name jwt

Name: rubygem-%{gem_name}
Version: 1.5.6
Release: 1%{?dist}
Summary: JSON Web Token implementation in Ruby
License: MIT
URL: http://github.com/jwt/ruby-jwt
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
# BuildRequires: rubygem(json) < 2.0
# BuildRequires: rubygem(rspec)
# BuildRequires: rubygem(simplecov)
# BuildRequires: rubygem(simplecov-json)
# BuildRequires: rubygem(codeclimate-test-reporter)
BuildArch: noarch

%description
A pure ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT)
standard.


%package doc
Summary: Documentation for %{name}
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
%setup -q -n %{gem_name}-%{version}

%build
# Create the gem as gem install only works on a gem file
gem build ../%{gem_name}-%{version}.gemspec

# %%gem_install compiles any C extensions and installs the gem into ./%%gem_dir
# by default, so that we can move it into the buildroot in %%install
%gem_install

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/



%check
pushd .%{gem_instdir}
# rspec spec
popd

%files
%dir %{gem_instdir}
%{gem_instdir}/.codeclimate.yml
%exclude %{gem_instdir}/.gitignore
%exclude %{gem_instdir}/.rubocop.yml
%exclude %{gem_instdir}/.travis.yml
%license %{gem_instdir}/LICENSE
%{gem_instdir}/Manifest
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%exclude %{gem_instdir}/.rspec
%doc %{gem_instdir}/CHANGELOG.md
%{gem_instdir}/Gemfile
%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile
%{gem_instdir}/ruby-jwt.gemspec
%{gem_instdir}/spec

%changelog
* Wed Sep 12 2018 Shirshendu Mukherjee <shirshendu.mukherjee.88@gmail.com> - 1.5.6-1
- Initial package
