# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
inherit distutils-r1 git-r3

DESCRIPTION="CLI tool that pipes video streams from services like twitch.tv into a video player"
HOMEPAGE="https://github.com/chrippa/livestreamer"
SRC_URI=""
EGIT_REPO_URI="git@github.com:chrippa/livestreamer.git
	https://github.com/chrippa/livestreamer.git"

KEYWORDS=""
LICENSE="Apache-2.0 BSD-2 MIT-with-advertising"
SLOT="0"

RDEPEND="
	>=dev-python/requests-1.0[${PYTHON_USEDEP}]
	virtual/python-futures[${PYTHON_USEDEP}]
	virtual/python-singledispatch[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

pkg_postinst(){
	elog "optional dependencies:"
	elog "  dev-python/pycrypto[${PYTHON_USEDEP}]"
	elog "  >media-video/rtmpdump-2.4"
}
