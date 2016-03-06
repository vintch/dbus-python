#!/bin/sh

# Copyright © 2016 Simon McVittie
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

set -e
set -x

NULL=
srcdir="$(pwd)"
builddir="$(mktemp -d -t "builddir.XXXXXX")"
prefix="$(mktemp -d -t "prefix.XXXXXX")"

if [ -n "$dbus_ci_parallel" ]; then
	dbus_ci_parallel=2
fi

if [ -n "$TRAVIS" ] && [ -n "$dbus_ci_system_python" ]; then
	# Reset to standard paths to use the Ubuntu version of python
	unset LDFLAGS
	unset PYTHONPATH
	unset PYTHON_CFLAGS
	unset PYTHON_CONFIGURE_OPTS
	unset VIRTUAL_ENV
	export PATH=/usr/bin:/bin
	PYTHON="$(command -v "$dbus_ci_system_python")"
elif [ -n "$TRAVIS_PYTHON_VERSION" ]; then
	# Possibly in a virtualenv
	dbus_ci_bindir="$(python -c 'import sys; print(sys.prefix)')"/bin
	# The real underlying paths, even if we have a virtualenv
	# e.g. /opt/pythonwhatever/bin on travis-ci
	dbus_ci_real_bindir="$(python -c 'import distutils.sysconfig; print(distutils.sysconfig.get_config_var("BINDIR"))')"
	dbus_ci_real_libdir="$(python -c 'import distutils.sysconfig; print(distutils.sysconfig.get_config_var("LIBDIR"))')"

	# We want the virtualenv bindir for python itself, then the real bindir
	# for python[X.Y]-config (which isn't copied into the virtualenv, so we
	# risk picking up the wrong one from travis-ci's PATH if we don't
	# do this)
	export PATH="${dbus_ci_bindir}:${dbus_ci_real_bindir}:${PATH}"
	# travis-ci's /opt/pythonwhatever/lib isn't on the library search path
	export LD_LIBRARY_PATH="${dbus_ci_real_libdir}"
	# travis-ci's Python 2 library is static, so it raises warnings
	# about tmpnam_r and tempnam
	case "$TRAVIS_PYTHON_VERSION" in
		(2*) export LDFLAGS=-Wl,--no-fatal-warnings;;
	esac
fi

# dbus-run-session is significantly nicer to debug than with-session-bus.sh,
# but isn't in the version of dbus in Ubuntu 14.10. Take the version from
# dbus-1.10.0 and alter it to be standalone.
if ! command -v dbus-run-session >/dev/null; then
	drsdir="$(mktemp -d -t "d-r-s.XXXXXX")"
	curl -o "$drsdir/dbus-run-session.c" \
		"https://cgit.freedesktop.org/dbus/dbus/plain/tools/dbus-run-session.c?h=dbus-1.10.0"
	sed -e 's/^	//' > "$drsdir/config.h" <<EOF
	#include <stdlib.h>

	#define VERSION "1.10.0~local"
	#define dbus_setenv my_dbus_setenv

	static inline int
	my_dbus_setenv (const char *name, const char *value)
	{
		if (value)
			return !setenv (name, value, 1);
		else
			return !unsetenv (name);
	}
EOF
	cc -I"${drsdir}" -o"${drsdir}/dbus-run-session" \
		"${drsdir}/dbus-run-session.c" \
		$(pkg-config --cflags --libs dbus-1) \
		${NULL}
	export PATH="${drsdir}:$PATH"
fi

NOCONFIGURE=1 ./autogen.sh

(
	cd "$builddir" && "${srcdir}/configure" \
		--enable-installed-tests \
		--prefix="$prefix" \
		${NULL}
)

make="make -j${dbus_ci_parallel} V=1 VERBOSE=1"

$make -C "$builddir"
$make -C "$builddir" check
$make -C "$builddir" distcheck
$make -C "$builddir" install
( cd "$prefix" && find . -ls )

dbus_ci_pyversion="$(${PYTHON:-python} -c 'import distutils.sysconfig; print(distutils.sysconfig.get_config_var("VERSION"))')"
export PYTHONPATH="$prefix/lib/python$dbus_ci_pyversion/site-packages:$PYTHONPATH"
export XDG_DATA_DIRS="$prefix/share:/usr/local/share:/usr/share"
gnome-desktop-testing-runner dbus-python

# re-run the tests with dbus-python only installed via pip
if [ -n "$VIRTUAL_ENV" ]; then
	rm -fr "${prefix}/lib/python$dbus_ci_pyversion/site-packages"
	pip install -vvv "${builddir}"/dbus-python-*.tar.gz
	gnome-desktop-testing-runner dbus-python
fi
