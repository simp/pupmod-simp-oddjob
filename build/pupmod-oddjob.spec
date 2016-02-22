Summary: OddJob Puppet Module
Name: pupmod-oddjob
Version: 1.0.0
Release: 2
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Requires: pupmod-simplib >= 1.0.0
Obsoletes: pupmod-oddjob-test

Prefix:"/etc/puppet/environments/simp/modules"

%description
This Puppet module provides the capability to configure the basics of
the OddJob subsystem.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/oddjob

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/oddjob
done

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/oddjob

%files
%defattr(0640,root,puppet,0750)
/etc/puppet/environments/simp/modules/oddjob

%post
#!/bin/sh

if [ -d /etc/puppet/environments/simp/modules/oddjob/plugins ]; then
  /bin/mv /etc/puppet/environments/simp/modules/oddjob/plugins /etc/puppet/environments/simp/modules/oddjob/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Mon Nov 09 2015 Chris Tessmer <chris.tessmer@onypoint.com> - 1.0.0-2
- migration to simplib and simpcat (lib/ only)

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0.0-1
- Changed puppet-server requirement to puppet

* Wed Jul 23 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 1.0.0-0
- Created the first cut at the oddjob module for use by PAM
