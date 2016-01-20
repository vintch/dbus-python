abs_top_srcdir = @abs_top_srcdir@
abs_top_builddir = @abs_top_builddir@

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = test

CLEANFILES =
EXTRA_DIST = \
	dbus-python.pc.in \
	AUTHORS \
	COPYING \
	ChangeLog \
	examples/example-async-client.py \
	examples/example-client.py \
	examples/example-service.py \
	examples/example-signal-emitter.py \
	examples/example-signal-recipient.py \
	examples/gconf-proxy-client.py \
	examples/gconf-proxy-service2.py \
	examples/list-system-services.py \
	examples/unix-fd-client.py \
	examples/unix-fd-service.py \
	m4/am-check-pymod.m4 \
	m4/am-check-python-headers.m4 \
	m4/dbus-py-add-rst2htmlflag.m4 \
	tools/check-coding-style.mk \
	tools/check-c-style.sh \
	tools/check-py-style.sh \
	tools/check-whitespace.sh
	$(NULL)

# === C code ===

AM_CPPFLAGS = \
	-I$(top_srcdir)/include \
	$(DBUS_CFLAGS) \
	$(DBUS_GLIB_CFLAGS) \
	$(PYTHON_INCLUDES) \
	$(NULL)
AM_CFLAGS = \
	$(WARN_CFLAGS) \
	$(NULL)
AM_LDFLAGS = \
	$(WARN_LDFLAGS) \
	$(NULL)

pymod_ldflags = \
	-module \
	-avoid-version \
	$(NULL)
pymod_libadd = \
	$(NULL)

if WINDOWS
# Win32 DLLs can't have undefined symbols (so this needs explicit linking
# against the Python DLL), and Python expects extensions to be *.pyd
# instead of *.dll
pymod_ldflags += \
	-no-undefined \
	-shrext ".pyd" \
	$(NULL)
pymod_libadd += \
	$(PYTHON_LIBS) \
	$(NULL)
endif

pyexec_LTLIBRARIES = \
	_dbus_bindings.la \
	_dbus_glib_bindings.la \
	$(NULL)

_dbus_bindings_la_LDFLAGS = \
	$(pymod_ldflags) \
	-export-symbols-regex \(PyInit__\|init_\)dbus_bindings \
	$(AM_LDFLAGS) \
	$(NULL)
_dbus_bindings_la_LIBADD = \
	$(pymod_libadd) \
	$(DBUS_LIBS) \
	$(NULL)
_dbus_bindings_la_SOURCES = \
	_dbus_bindings/abstract.c \
	_dbus_bindings/bus.c \
	_dbus_bindings/bytes.c \
	_dbus_bindings/compat-internal.h \
	_dbus_bindings/conn.c \
	_dbus_bindings/conn-internal.h \
	_dbus_bindings/conn-methods.c \
	_dbus_bindings/containers.c \
	_dbus_bindings/dbus_bindings-internal.h \
	_dbus_bindings/debug.c \
	_dbus_bindings/exceptions.c \
	_dbus_bindings/float.c \
	_dbus_bindings/generic.c \
	_dbus_bindings/int.c \
	_dbus_bindings/unixfd.c \
	_dbus_bindings/libdbusconn.c \
	_dbus_bindings/mainloop.c \
	_dbus_bindings/message-append.c \
	_dbus_bindings/message.c \
	_dbus_bindings/message-get-args.c \
	_dbus_bindings/message-internal.h \
	_dbus_bindings/module.c \
	_dbus_bindings/pending-call.c \
	_dbus_bindings/server.c \
	_dbus_bindings/signature.c \
	_dbus_bindings/string.c \
	_dbus_bindings/types-internal.h \
	_dbus_bindings/validation.c \
	$(NULL)

_dbus_glib_bindings_la_LDFLAGS = \
	$(pymod_ldflags) \
	-export-symbols-regex \(PyInit__\|init_\)dbus_glib_bindings \
	$(AM_LDFLAGS) \
	$(NULL)
_dbus_glib_bindings_la_LIBADD = \
	$(pymod_libadd) \
	$(DBUS_LIBS) \
	$(DBUS_GLIB_LIBS) \
	$(NULL)
_dbus_glib_bindings_la_SOURCES = \
	_dbus_glib_bindings/module.c \
	$(NULL)

# === dbus package ===

nobase_python_PYTHON = \
    dbus/bus.py \
    dbus/connection.py \
    dbus/_compat.py \
    dbus/_dbus.py \
    dbus/_version.py \
    dbus/decorators.py \
    dbus/exceptions.py \
    dbus/_expat_introspect_parser.py \
    dbus/gi_service.py \
    dbus/glib.py \
    dbus/__init__.py \
    dbus/lowlevel.py \
    dbus/mainloop/__init__.py \
    dbus/mainloop/glib.py \
    dbus/proxies.py \
    dbus/server.py \
    dbus/service.py \
    dbus/types.py

if !HAVE_PYTHON_3
nobase_python_PYTHON += \
    dbus/gobject_service.py \
    $(NULL)
endif

check_py_sources = $(nobase_python_PYTHON)
include $(top_srcdir)/tools/check-coding-style.mk

# === Devel stuff ===

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = dbus-python.pc

dbusincludedir = $(includedir)/dbus-1.0/dbus
dbusinclude_HEADERS = include/dbus-python.h

# === Tests ===

cross-test-compile: all
cross-test-server:
	@$(MAKE) -C test cross-test-server
cross-test-client:
	@$(MAKE) -C test cross-test-client

# === Documentation ===

dist-hook:
	chmod u+w $(distdir)/ChangeLog
	if test -d $(top_srcdir)/.git; then \
		if GIT_DIR=$(top_srcdir)/.git git log --stat > $(distdir)/ChangeLog; then \
			: ; \
		else \
			GIT_DIR=$(top_srcdir)/.git git log > $(distdir)/ChangeLog; \
		fi; \
	fi

TXT_RSTDOCS = \
	doc/tutorial.txt \
	doc/API_CHANGES.txt \
	doc/HACKING.txt \
	doc/PY3PORT.txt \
	$(NULL)
RSTDOCS = \
	README \
	NEWS \
	$(NULL)
dist_doc_DATA = $(TXT_RSTDOCS) $(RSTDOCS)

maintainer-upload:
	rsync -tvpP --chmod=ugo=r $(DIST_ARCHIVES) $(DIST_ARCHIVES:%=%.asc) \
	dbus.freedesktop.org:/srv/dbus.freedesktop.org/www/releases/dbus-python/

maintainer-update-website: _maintainer-update-apidocs \
	_maintainer-update-htmldocs

if ENABLE_DOCS
_maintainer-update-htmldocs: $(HTML_TXT_RSTDOCS) $(HTML_RSTDOCS)
	rsync -rtvzPp --chmod=Dg+s,ug+rwX,o=rX doc \
	$(patsubst %,$(srcdir)/%,$(RSTDOCS)) $(HTML_RSTDOCS) \
	dbus.freedesktop.org:/srv/dbus.freedesktop.org/www/doc/dbus-python/

HTML_TXT_RSTDOCS = $(patsubst %.txt,%.html,$(TXT_RSTDOCS))
HTML_RSTDOCS = $(patsubst %,%.html,$(RSTDOCS))
nodist_doc_DATA = $(HTML_TXT_RSTDOCS) $(HTML_RSTDOCS)

CLEANFILES += $(nodist_doc_DATA)

$(HTML_TXT_RSTDOCS) : %.html: %.txt
	$(INSTALL) -d doc
	$(RST2HTML) $(RST2HTMLFLAGS) $< $@
$(HTML_RSTDOCS) : %.html: %
	$(RST2HTML) $(RST2HTMLFLAGS) $< $@
else
_maintainer-update-htmldocs:
	@echo "*** Not updating the HTML docs on the website - install rst2html"
	@echo "*** from http://docutils.sourceforge.net/ and configure with "
	@echo "*** --enable-html-docs"
endif

if ENABLE_API_DOCS
all: api/index.html

clean-local:
	rm -rf api

APIDOC_PYTHONPATH = $(abs_top_srcdir):$(abs_top_builddir)/.libs

api api/index.html: $(nobase_python_PYTHON) \
		    _dbus_bindings.la \
		    _dbus_glib_bindings.la
	rm -rf api
	mkdir api
	cd $(abs_top_srcdir) && \
	PYTHONPATH=$(APIDOC_PYTHONPATH) DBUS_PYTHON_NO_DEPRECATED=1 \
	$(PYTHON) -Wignore::DeprecationWarning \
	$(EPYDOC) -o $(abs_top_builddir)/api --html \
		--docformat restructuredtext -v \
		`find dbus -name '*.py' \
			| sed -e 's#/__init__\.py##g' \
				-e 's/\.py\>//g' -e 's#/#.#'g` \
		|| { rm -rf api; exit 1; }

_maintainer-update-apidocs: api
	rsync -rtvzPp --chmod=Dg+s,ug+rwX,o=rX api/ \
	dbus.freedesktop.org:/srv/dbus.freedesktop.org/www/doc/dbus-python/api/
else
_maintainer-update-apidocs:
	@echo "*** Not updating the API docs on the website - install epydoc 3"
	@echo "*** alpha (or newer) and configure with --enable-api-docs"
endif

check_c_sources = \
	$(_dbus_bindings_la_SOURCES) \
	$(_dbus_glib_bindings_la_SOURCES) \
	$(NULL)

include $(top_srcdir)/tools/check-coding-style.mk

.PHONY: cross-test-compile cross-test-server cross-test-client \
	always-rebuild maintainer-update-website \
	_maintainer-update-apidocs _maintainer-update-htmldocs \
	maintainer-upload
