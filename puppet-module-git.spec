Name:		puppet-module-git
Summary:	Puppet module for git
Group:		Applications/System
Version:	0.0.1
Release:	1
License:	GPLv3+
URL:		http://puppetmanaged.org/
Source0:	http://puppetmanaged.org/releases/puppet-module-git-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch

BuildRequires:	publican
Requires:	puppet-server

%description
Puppet module for managing yum

%prep
%setup -q

%build
cd documentation
make pdf-en-US
mv tmp/en-US/pdf/Git_Module.pdf ..

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make install DESTDIR=%{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc COPYING Git_Module.pdf
/var/lib/puppet/modules/git

%changelog
* Thu Sep 25 2008 Jeroen van Meeuwen <kanarip@kanarip.com> - 0.0.1-1
- First packaged version
