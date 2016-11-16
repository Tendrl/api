# Generated from etcd-0.3.0.gem by gem2rpm -*- rpm-spec -*-
%global gem_name etcd

Name: rubygem-%{gem_name}
Version: 0.3.0
Release: 1%{?dist}
Summary: Ruby client library for etcd
Group: Development/Languages
License: MIT
URL: https://github.com/ranjib/etcd-ruby
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby >= 1.9
# BuildRequires: rubygem(uuid)
# BuildRequires: rubygem(rspec)
BuildArch: noarch

%description
Ruby client library for etcd.


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
%{gem_instdir}/.coco.yml
%exclude %{gem_instdir}/.gitignore
%{gem_instdir}/.rspec
%exclude %{gem_instdir}/.rubocop.yml
%exclude %{gem_instdir}/.travis.yml
%{gem_instdir}/Guardfile
%license %{gem_instdir}/LICENSE.txt
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%{gem_instdir}/Gemfile
%doc %{gem_instdir}/README.md
%{gem_instdir}/Rakefile
%{gem_instdir}/etcd.gemspec
%{gem_instdir}/spec

%changelog
* Tue Nov 15 2016 Tim <tim.gluster@gmail.com> - 0.3.0-1
- Initial package
