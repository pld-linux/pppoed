#
# TODO:
# - cleanups, initd start script, description, BR/R,
# 
Summary:	PPPoE server package for Linux
Summary(pl):	Serwer PPPoE dla Linuksa
Name:		pppoed
Version:	0.48b1
Release:	0.1
License:	GPL
Group:		Networking/Daemons
Source0:	http://jamal.davintech.ca/pppoe/%{name}-0.48b1.tgz
# Source0-md5:	f6b29ecf829f95681e5a11c4b47cfa99
Patch0:		%{name}-termchar.patch
URL:		http://www.davin.ottawa.on.ca/pppoe/
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description

%description -l pl

%prep
%setup -q -n %{name}-%{version}
%patch -p1

%build
cd pppoed
%configure2_13
%{__make} \
	OPT_FLAGS="%{rpmcflags}" \
	CC=%{__cc}

%install
rm -rf $RPM_BUILD_ROOT

cd pppoed
%{__make} install \
	DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%doc pppoed/README* pppoed/AUTHORS contribs docs/*
%attr(755,root,root) %{_sbindir}/ppp*
%{_mandir}/man8/*
