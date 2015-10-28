# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

## BUNDLED-DEPS:
# extern/cuew
# extern/Eigen3
# extern/xdnd
# extern/carve
# extern/glew
# extern/libmv
# extern/clew
# extern/colamd
# extern/lzma
# extern/gtest
# extern/rangetree
# extern/libredcode
# extern/wcwidth
# extern/binreloc
# extern/recastnavigation
# extern/bullet2
# extern/lzo
# extern/libopenjpeg
# extern/libmv/third_party/msinttypes
# extern/libmv/third_party/ceres
# extern/libmv/third_party/gflags
# extern/libmv/third_party/glog

EAPI=5
PYTHON_COMPAT=( python3_4 python3_5 )

EGIT_REPO_URI="git://git.blender.org/blender.git"

inherit multilib fdo-mime gnome2-utils cmake-utils eutils python-single-r1 versionator flag-o-matic toolchain-funcs pax-utils check-reqs git-r3

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS=""
IUSE="+boost +bullet c++0x collada colorio cycles +dds debug +elbeem ffmpeg fftw +game-engine jack jpeg2k libav ndof nls openal openimageio +opennl openmp +openexr player redcode sdl sndfile cpu_flags_x86_sse cpu_flags_x86_sse2 tiff"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	player? ( game-engine )
	redcode? ( jpeg2k ffmpeg )
	cycles? ( boost openexr tiff )
	nls? ( boost )
	game-engine? ( boost )"

RDEPEND="${PYTHON_DEPS}
	dev-libs/lzo:2
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	>=media-libs/freetype-2.0:2
	media-libs/glew
	media-libs/libpng:0
	media-libs/libsamplerate
	sci-libs/ldl
	sys-libs/zlib
	virtual/glu
	virtual/jpeg:0
	virtual/libintl
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXxf86vm
	boost? ( >=dev-libs/boost-1.44[nls?,threads(+)] )
	collada? ( >=media-libs/opencollada-9999 )
	colorio? ( media-libs/opencolorio )
	cycles? (
		media-libs/openimageio
	)
	ffmpeg? (
		!libav? ( >=media-video/ffmpeg-2.1.4:0=[x264,mp3,encode,theora,jpeg2k?] )
		libav? ( >=media-video/libav-9:0=[x264,mp3,encode,theora,jpeg2k?] )
	)
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg2k? ( media-libs/openjpeg:0 )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.6.372 )
	openimageio? ( media-libs/openimageio )
	openexr? ( media-libs/ilmbase media-libs/openexr )
	sdl? ( media-libs/libsdl2[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )
"
DEPEND="${RDEPEND}
	>=dev-cpp/eigen-3.2.4:3
	nls? ( sys-devel/gettext )"

pkg_pretend() {
	if use openmp && ! tc-has-openmp; then
		eerror "You are using gcc built without 'openmp' USE."
		eerror "Switch CXX to an OpenMP capable compiler."
		die "Need openmp"
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.68-fix-install-rules.patch
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char
	append-lfs-flags

	# WITH_PYTHON_SECURITY
	# WITH_PYTHON_SAFETY
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DWITH_INSTALL_PORTABLE=OFF
		$(cmake-utils_use_with boost BOOST)
		$(cmake-utils_use_with bullet BULLET)
		$(cmake-utils_use_with ffmpeg CODEC_FFMPEG)
		$(cmake-utils_use_with sndfile CODEC_SNDFILE)
		$(cmake-utils_use_with c++0x CPP11)
		$(cmake-utils_use_with cycles CYCLES)
		$(cmake-utils_use_with fftw FFTW3)
		$(cmake-utils_use_with game-engine GAMEENGINE)
		$(cmake-utils_use_with dds IMAGE_DDS)
		$(cmake-utils_use_with openexr IMAGE_OPENEXR)
		$(cmake-utils_use_with jpeg2k IMAGE_OPENJPEG)
		$(cmake-utils_use_with redcode IMAGE_REDCODE)
		$(cmake-utils_use_with tiff IMAGE_TIFF)
		$(cmake-utils_use_with ndof INPUT_NDOF)
		$(cmake-utils_use_with nls INTERNATIONAL)
		$(cmake-utils_use_with jack JACK)
		$(cmake-utils_use_with elbeem MOD_FLUID)
		$(cmake-utils_use_with fftw MOD_OCEANSIM)
		$(cmake-utils_use_with openal OPENAL)
		-DWITH_OPENCOLLADA=OFF
		$(cmake-utils_use_with colorio OPENCOLORIO)
		$(cmake-utils_use_with openimageio OPENIMAGEIO)
		$(cmake-utils_use_with openmp OPENMP)
		$(cmake-utils_use_with opennl OPENNL)
		$(cmake-utils_use_with player PLAYER)
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		$(cmake-utils_use_with cpu_flags_x86_sse RAYOPTIMIZATION)
		$(cmake-utils_use_with sdl SDL)
		$(cmake-utils_use_with cpu_flags_x86_sse2 SSE2)
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_BULLET=OFF
		-DWITH_SYSTEM_EIGEN3=ON
		-DWITH_SYSTEM_LZO=ON
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_test() { :; }

src_install() {
	local i

	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	# fucked up cmake will relink binary for no reason
	emake -C "${CMAKE_BUILD_DIR}" DESTDIR="${D}" install/fast

	# fix doc installdir
	dohtml "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED%/}"/usr/share/doc/blender || die

	python_fix_shebang "${ED%/}"/usr/bin/blender-thumbnailer.py
	python_optimize "${ED%/}"/usr/share/blender/${PV}/scripts
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherit risks with running unknown python scripting."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
	elog
	ewarn
	ewarn "This ebuild does not unbundle the massive amount of 3rd party"
	ewarn "libraries which are shipped with blender. Note that"
	ewarn "these have caused security issues in the past."
	ewarn "If you are concerned about security, file a bug upstream:"
	ewarn "  https://developer.blender.org/"
	ewarn
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

