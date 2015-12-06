abs_top_srcdir = @abs_top_srcdir@
abs_top_builddir = @abs_top_builddir@

EXTRA_DIST = \
	     cross-test-client.py \
	     cross-test-server.py \
	     crosstest.py \
	     run-test.sh \
	     test-client.py \
	     test-exception-py2.py \
	     test-exception-py3.py \
	     test-p2p.py \
	     test-service.py \
	     test-signals.py \
	     test-standalone.py \
	     test-unusable-main-loop.py \
	     TestSuitePythonService.service.in \
	     tmp-session-bus.conf.in \
	     with-session-bus.sh \
	     $(NULL)

# If you try to make this noinst, libtool helpfully gives us a static
# library, which doesn't work as a Python extension: so force the install
# target not to work here instead.
pyexec_LTLIBRARIES = dbus_py_test.la

install:
	@echo "Not installing anything from test/"

AM_CPPFLAGS = \
	-I$(top_srcdir)/include \
	$(DBUS_CFLAGS) \
	$(PYTHON_INCLUDES) \
	$(NULL)
AM_CFLAGS = \
	$(WARN_CFLAGS) \
	$(NULL)
AM_LDFLAGS = \
	-module \
	-avoid-version \
	$(WARN_LDFLAGS) \
	$(NULL)

dbus_py_test_la_LIBADD = $(DBUS_LIBS)
dbus_py_test_la_SOURCES = \
	dbus_py_test.c \
	$(top_srcdir)/include/dbus-python.h

AM_TESTS_ENVIRONMENT = \
	export DBUS_TOP_SRCDIR="$(abs_top_srcdir)"; \
	export DBUS_TOP_BUILDDIR="$(abs_top_builddir)"; \
	export DBUS_PYTHON_VERSION='$(PACKAGE_VERSION)'; \
	export PYTHONPATH="$(abs_top_builddir)/test/.libs:$(abs_top_srcdir):$(abs_top_srcdir)/test:$(abs_top_builddir)/_dbus_bindings/.libs:$(abs_top_builddir)/_dbus_glib_bindings/.libs"; \
	export PYTHON='$(PYTHON)'; \
	export DBUS_FATAL_WARNINGS=1; \
	$(NULL)

TEST_EXTENSIONS = .sh .py

if HAVE_DBUS_RUN_SESSION
LOG_COMPILER = $(DBUS_RUN_SESSION) \
	--config-file=tmp-session-bus.conf \
	--
else
LOG_COMPILER = \
	$(top_srcdir)/test/with-session-bus.sh \
	--config-file=tmp-session-bus.conf \
	--
endif

SH_LOG_COMPILER = $(LOG_COMPILER) $(SHELL)
PY_LOG_COMPILER = $(LOG_COMPILER) $(PYTHON)

TESTS = \
	run-test.sh \
	test-client.py \
	test-import-repeatedly \
	test-p2p.py \
	test-signals.py \
	test-standalone.py \
	test-unusable-main-loop.py \
	$(NULL)

if HAVE_PYTHON_3
TESTS += test-exception-py3.py
else
TESTS += test-exception-py2.py
endif

check_PROGRAMS = test-import-repeatedly

test_import_repeatedly_SOURCES = import-repeatedly.c
test_import_repeatedly_CPPFLAGS = $(PYTHON_INCLUDES)
test_import_repeatedly_LDADD = $(PYTHON_LIBS)

cross-test-server:
	$(AM_TESTS_ENVIRONMENT) $(PYTHON) $(top_srcdir)/test/cross-test-server.py
cross-test-client:
	$(AM_TESTS_ENVIRONMENT) $(PYTHON) $(top_srcdir)/test/cross-test-client.py

.PHONY: cross-test-compile cross-test-server cross-test-client
