#!/bin/sh

set -e
set -u
NULL=

sudo apt-get -qq -y update
sudo apt-get -qq -y install \
    autoconf \
    automake \
    ccache \
    dbus \
    gnome-desktop-testing \
    libdbus-1-dev \
    libtool \
    ${NULL}

if [ -n "${dbus_ci_system_python-}" ]; then
      sudo apt-get -qq -y install \
        ${dbus_ci_system_python} \
        ${dbus_ci_system_python%-dbg}-docutils \
        ${dbus_ci_system_python%-dbg}-gi \
        ${dbus_ci_system_python%-dbg}-pip \
        ${dbus_ci_system_python%-dbg}-setuptools \
        ${NULL}

    if [ "${dbus_ci_system_python%-dbg}" != "${dbus_ci_system_python}" ]; then
        sudo apt-get -qq -y install ${dbus_ci_system_python%-dbg}-gi-dbg
    fi

    if [ "$dbus_ci_system_python" = python ]; then
        sudo apt-get -qq -y install python-gobject-2
    fi
fi

wget \
http://deb.debian.org/debian/pool/main/a/autoconf-archive/autoconf-archive_20160916-1_all.deb
sudo dpkg -i autoconf-archive_*_all.deb
rm autoconf-archive_*_all.deb

if [ -n "${dbus_ci_system_python-}" ]; then
    "$dbus_ci_system_python" -m pip install --user \
        sphinx \
        sphinx_rtd_theme \
        tap.py \
        ${NULL}
else
    pip install \
        sphinx \
        sphinx_rtd_theme \
        tap.py \
        ${NULL}
fi
