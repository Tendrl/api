# Generated from sinatra-1.4.5.gem by gem2rpm -*- rpm-spec -*-
%global gem_name sinatra

Name: rubygem-%{gem_name}
Version: 1.4.5
Release: 1%{?dist}
Summary: Classy web-development dressed in a DSL
Group: Development/Languages
License: MIT
URL: http://www.sinatrarb.com/
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
BuildArch: noarch

%description
Sinatra is a DSL for quickly creating web applications in Ruby with minimal
effort.


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
%exclude %{gem_instdir}/.yardopts
%{gem_instdir}/CHANGES
%license %{gem_instdir}/LICENSE
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/AUTHORS
%{gem_instdir}/Gemfile
%doc %{gem_instdir}/README.de.md
%doc %{gem_instdir}/README.es.md
%doc %{gem_instdir}/README.fr.md
%doc %{gem_instdir}/README.hu.md
%doc %{gem_instdir}/README.ja.md
%doc %{gem_instdir}/README.ko.md
%doc %{gem_instdir}/README.md
%doc %{gem_instdir}/README.pt-br.md
%doc %{gem_instdir}/README.pt-pt.md
%doc %{gem_instdir}/README.ru.md
%doc %{gem_instdir}/README.zh.md
%{gem_instdir}/Rakefile
%{gem_instdir}/examples
%{gem_instdir}/sinatra.gemspec
%{gem_instdir}/test

%changelog
* Mon Nov 21 2016 Tim <tim.gluster@gmail.com> - 1.4.5-1
- Initial package
