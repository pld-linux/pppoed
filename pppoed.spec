#
# TODO:
# - cleanups, description, BR/R,
#
Summary:	PPPoE server package for Linux
Summary(pl):	Serwer PPPoE dla Linuksa
Name:		pppoed
Version:	0.48b1
Release:	0.1
License:	GPL
Group:		Networking/Daemons
Source0:	http://jamal.davintech.ca/pppoe/%{name}-%{version}.tgz
# Source0-md5:	f6b29ecf829f95681e5a11c4b47cfa99
Source1:	%{name}.initd
Source2:	%{name}.sysconfig
Source3:	%{name}-setup.sh
Patch0:		%{name}-termchar.patch
URL:		http://www.davin.ottawa.on.ca/pppoe/
#Requires:	ppp
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description

%description -l pl

%prep
%setup -q
%patch0 -p1

%build
cd pppoed
%configure2_13
%{__make} \
	OPT_FLAGS="%{rpmcflags}" \
	CC="%{__cc}"

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/etc/{rc.d/init.d,sysconfig}

cd pppoed
%{__make} install \
	DESTDIR=$RPM_BUILD_ROOT

install %{SOURCE1} $RPM_BUILD_ROOT/etc/rc.d/init.d/%{name}
install %{SOURCE2} $RPM_BUILD_ROOT/etc/sysconfig/%{name}
install %{SOURCE3} $RPM_BUILD_ROOT%{_sbindir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%doc QUICK-INSTALL-example pppoed/README* pppoed/INSTALL pppoed/AUTHORS contribs docs/*
%attr(755,root,root) %{_sbindir}/ppp*
%attr(754,root,root) /etc/rc.d/init.d/%{name}
%attr(640,root,root) %config(noreplace) %verify(not md5 mtime size) /etc/sysconfig/%{name}
%{_mandir}/man8/*
