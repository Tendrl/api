# Generated from sinatra-cross_origin-0.4.0.gem by gem2rpm -*- rpm-spec -*-
%global gem_name sinatra-cross_origin

Name: rubygem-%{gem_name}
Version: 0.4.0
Release: 1%{?dist}
Summary: Cross Origin Resource Sharing helper for Sinatra
Group: Development/Languages
License: LGPLV2+
URL: http://github.com/britg/sinatra-cross_origin
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
BuildArch: noarch

%description
Cross Origin Resource Sharing helper for Sinatra.


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
%license %{gem_instdir}/LICENSE
%{gem_instdir}/VERSION
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/README.markdown
%{gem_instdir}/Rakefile
%{gem_instdir}/sinatra-cross_origin.gemspec
%{gem_instdir}/test

%changelog
* Wed Nov 16 2016 Tim <tim.gluster@gmail.com> - 0.4.0-1
- Initial package
