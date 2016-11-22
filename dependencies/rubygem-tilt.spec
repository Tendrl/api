%global gem_name tilt

%global bootstrap 1

Summary: Generic interface to multiple Ruby template engines
Name: rubygem-%{gem_name}
Version: 1.4.1
Release: 3%{?dist}
Group: Development/Languages
License: MIT
URL: http://github.com/rtomayko/%{gem_name}
Source0: http://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
%if 0%{bootstrap} < 1
BuildRequires: rubygem(creole)
BuildRequires: rubygem(minitest)
BuildRequires: rubygem(nokogiri)
BuildRequires: rubygem(erubis)
BuildRequires: rubygem(haml)
BuildRequires: rubygem(builder)
BuildRequires: rubygem(maruku)
BuildRequires: rubygem(RedCloth)
BuildRequires: rubygem(redcarpet)
BuildRequires: rubygem(coffee-script)
BuildRequires: rubygem(therubyracer)
BuildRequires: rubygem(wikicloth)

# BuildRequires: rubygem(asciidoctor)
#BuildRequires: rubygem(kramdown)
# Markaby test fails. It is probably due to rather old version found in Fedora.
# https://github.com/rtomayko/tilt/issues/96
# BuildRequires: rubygem(markaby)
#BuildRequires: rubygem(rdiscount)
%endif
%if 0%{?fc20} || 0%{?el7}
Provides: rubygem(%{gem_name}) = %{version}
%endif

BuildArch: noarch

%description
Generic interface to multiple Ruby template engines


%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires:%{name} = %{version}-%{release}

%description doc
Documentation for %{name}

%prep
%setup -q -c -T
%gem_install -n %{SOURCE0}

pushd .%{gem_instdir}
popd

%build

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
   %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{_bindir}
cp -a .%{_bindir}/* \
   %{buildroot}%{_bindir}/

find %{buildroot}%{gem_instdir}/bin -type f | xargs chmod a+x

%check
%if 0%{bootstrap} < 1
pushd %{buildroot}%{gem_instdir}
popd
%endif

%files
%dir %{gem_instdir}
%{_bindir}/%{gem_name}
%exclude %{gem_instdir}/%{gem_name}.gemspec
%exclude %{gem_instdir}/.*
%exclude %{gem_instdir}/Gemfile
%{gem_instdir}/bin
%{gem_libdir}
%doc %{gem_instdir}/COPYING
%doc %{gem_instdir}/README.md
%doc %{gem_instdir}/TEMPLATES.md
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/CHANGELOG.md
%doc %{gem_instdir}/HACKING
%{gem_instdir}/Rakefile
%{gem_instdir}/test


%changelog
* Mon Nov 21 2016 Tim <tim.gluster@gmail.com> - 1.4.1-1
- Initial package
