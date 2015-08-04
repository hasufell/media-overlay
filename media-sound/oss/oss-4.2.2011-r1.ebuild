# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils toolchain-funcs

MY_P=oss-v${PV:0:3}-build${PV:4}-src-gpl

DESCRIPTION="Open Sound System - applications and man pages"
HOMEPAGE="http://developer.opensound.com/"
SRC_URI="http://www.4front-tech.com/developer/sources/stable/gpl/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk salsa vmix-float"

RDEPEND="gtk? ( x11-libs/gtk+:2 )"
DEPEND="${RDEPEND}
	app-text/txt2man
	sys-apps/gawk
	>=sys-kernel/linux-headers-2.6.11"

S=${WORKDIR}/${MY_P}
BUILD_DIR=${WORKDIR}/${PN}-build

src_prepare() {
	mkdir "${BUILD_DIR}" || die
	epatch "${FILESDIR}"/${P}-{CFLAGS,as-needed-strip,filesystem-layout,txt2man,linux-4.x}.patch
}

src_configure() {
	cd "${BUILD_DIR}" || die

	HOSTCC=$(tc-getCC) \
	NO_WARNING_CHECKS=1 \
	"${S}"/configure \
		--config-midi=YES \
		$(usex salsa "" "--enable-libsalsa=NO") \
		$(usex vmix-float "--config-vmix=FLOAT" "") || die
}

src_compile() {
	cd "${BUILD_DIR}" || die

	pushd lib >/dev/null || die
	einfo "Building libraries"
	emake CC=$(tc-getCC)
	popd >/dev/null || die

	pushd cmd >/dev/null || die
	if ! use gtk; then
		# remove ossxmix from SUBDIRS
		sed -i \
			-e "s:ossxmix::" \
			Makefile || die
	fi

	einfo "Building applications"
	emake CC=$(tc-getCC)
	popd >/dev/null || die

	pushd os_cmd/Linux >/dev/null || die
	einfo "Building ossdetect/ossvermagic"
	emake CC=$(tc-getCC)
	popd >/dev/null || die
}

src_install() {
	cd "${BUILD_DIR}" || die
	use salsa && dolib lib/libsalsa/.libs/libsalsa.so*

	dolib lib/libOSSlib/libOSSlib.so

	# install man pages
	use gtk || { rm cmd/ossxmix/ossxmix.man || die ; }
	rename man 1 cmd/*/*.man || die
	doman cmd/*/*.1
	rename .man .7 misc/man7/*.man || die
	doman misc/man7/*.7
	rename man 7 kernel/drv/*/*.man || die
	doman kernel/drv/*/*.7
	newman os_cmd/Linux/ossdetect/ossdetect.man ossdetect.8
	newman noregparm/cmd/ossdevlinks/ossdevlinks.man ossdevlinks.8
	newman noregparm/cmd/savemixer/savemixer.man savemixer.8
	newman noregparm/cmd/vmixctl/vmixctl.man vmixctl.8

	insinto /etc/oss4
	doins devices.list
	newins .version version.dat
	cat > "${ED}"/etc/oss.conf << EOF || die
OSSETCDIR=/etc/oss4
OSSVARDIR=/var/lib/oss4
EOF

	cd target || die
	dosbin sbin/*
	dobin bin/*
	dolib lib/*

	dosbin "${S}"/setup/Linux/sbin/*

	dodir /var/lib/oss4

	newinitd "${FILESDIR}"/${PN}.init ${PN}
	newconfd "${FILESDIR}"/${PN}.conf ${PN}
}

