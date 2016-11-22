# Generated from minitest-5.9.1.gem by gem2rpm -*- rpm-spec -*-
%global gem_name minitest

Name: rubygem-%{gem_name}
Version: 5.9.1
Release: 1%{?dist}
Summary: minitest provides a complete suite of testing facilities supporting TDD, BDD, mocking, and benchmarking
Group: Development/Languages
License: MIT
URL: https://github.com/seattlerb/minitest
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
# BuildRequires: rubygem(hoe) => 3.15
# BuildRequires: rubygem(hoe) < 4
BuildArch: noarch

%description
minitest provides a complete suite of testing facilities supporting
TDD, BDD, mocking, and benchmarking.
"I had a class with Jim Weirich on testing last week and we were
allowed to choose our testing frameworks. Kirk Haines and I were
paired up and we cracked open the code for a few test
frameworks...
I MUST say that minitest is *very* readable / understandable
compared to the 'other two' options we looked at. Nicely done and
thank you for helping us keep our mental sanity."
-- Wayne E. Seguin
minitest/test is a small and incredibly fast unit testing framework.
It provides a rich set of assertions to make your tests clean and
readable.
minitest/spec is a functionally complete spec engine. It hooks onto
minitest/test and seamlessly bridges test assertions over to spec
expectations.
minitest/benchmark is an awesome way to assert the performance of your
algorithms in a repeatable manner. Now you can assert that your newb
co-worker doesn't replace your linear algorithm with an exponential
one!
minitest/mock by Steven Baker, is a beautifully tiny mock (and stub)
object framework.
minitest/pride shows pride in testing and adds coloring to your test
output. I guess it is an example of how to write IO pipes too. :P
minitest/test is meant to have a clean implementation for language
implementors that need a minimal set of methods to bootstrap a working
test suite. For example, there is no magic involved for test-case
discovery.
"Again, I can't praise enough the idea of a testing/specing
framework that I can actually read in full in one sitting!"
-- Piotr Szotkowski
Comparing to rspec:
rspec is a testing DSL. minitest is ruby.
-- Adam Hawkins, "Bow Before MiniTest"
minitest doesn't reinvent anything that ruby already provides, like:
classes, modules, inheritance, methods. This means you only have to
learn ruby to use minitest and all of your regular OO practices like
extract-method refactorings still apply.


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
%{gem_instdir}/.autotest
%{gem_instdir}/Manifest.txt
%{gem_instdir}/design_rationale.rb
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/History.rdoc
%doc %{gem_instdir}/README.rdoc
%{gem_instdir}/Rakefile
%{gem_instdir}/test

%changelog
* Mon Nov 21 2016 Tim <tim.gluster@gmail.com> - 5.9.1-1
- Initial package
