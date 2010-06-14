Name:		puppet-module-git
Summary:	Puppet module for git
Group:		Applications/System
Version:	0.5.0
Release:	1
License:	GPLv3+
URL:		http://puppetmanaged.org/
Source0:	http://puppetmanaged.org/releases/puppet-module-git-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch

BuildRequires:	publican
Requires:	puppet-server

%description
Puppet module for managing Git repositories both server as well as client-side

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make install DESTDIR=%{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc COPYING README
%{_localstatedir}/lib/puppetmanaged.org/modules/git

%changelog
* Mon Jun 14 2010 Jeroen van Meeuwen <kanarip@kanarip.com> - 0.5.0-1
- Release to forge.puppetlabs.com

* Thu Sep 25 2008 Jeroen van Meeuwen <kanarip@kanarip.com> - 0.0.1-1
- First packaged version
