#! /bin/bash

# Copyright (C) 2006 Red Hat Inc. <http://www.redhat.com/>
# Copyright (C) 2006-2007 Collabora Ltd. <http://www.collabora.co.uk/>
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

failed=
skipped=

dbus-monitor > "$DBUS_TOP_BUILDDIR"/test/monitor.log &

echo "DBUS_TOP_SRCDIR=$DBUS_TOP_SRCDIR"
echo "DBUS_TOP_BUILDDIR=$DBUS_TOP_BUILDDIR"
echo "PYTHONPATH=$PYTHONPATH"
echo "PYTHON=$PYTHON"

#echo "running the examples"

#$PYTHON "$DBUS_TOP_SRCDIR"/examples/example-service.py &
#$PYTHON "$DBUS_TOP_SRCDIR"/examples/example-signal-emitter.py &
#$PYTHON "$DBUS_TOP_SRCDIR"/examples/list-system-services.py --session ||
#  die "list-system-services.py --session failed!"
#$PYTHON "$DBUS_TOP_SRCDIR"/examples/example-async-client.py ||
#  die "example-async-client failed!"
#$PYTHON "$DBUS_TOP_SRCDIR"/examples/example-client.py --exit-service ||
#  die "example-client failed!"
#$PYTHON "$DBUS_TOP_SRCDIR"/examples/example-signal-recipient.py --exit-service ||
#  die "example-signal-recipient failed!"

echo "running cross-test (for better diagnostics use mjj29's dbus-test)"

$PYTHON "$DBUS_TOP_SRCDIR"/test/cross-test-server.py > "$DBUS_TOP_BUILDDIR"/test/cross-server.log &
sleep 1
$PYTHON "$DBUS_TOP_SRCDIR"/test/cross-test-client.py > "$DBUS_TOP_BUILDDIR"/test/cross-client.log
e=$?
echo "test-client exit status: $e"

if test $e = 77; then
  echo "cross-test-client exited $e, marking as skipped"
  skipped=yes
elif grep . "$DBUS_TOP_BUILDDIR"/test/cross-client.log >/dev/null; then
  echo "OK, cross-test-client produced some output"
else
  echo "cross-test-client produced no output" >&2
  failed=yes
fi

if test $e = 77; then
  echo "test-client exited $e, marking as skipped"
  skipped=yes
elif grep . "$DBUS_TOP_BUILDDIR"/test/cross-server.log >/dev/null; then
  echo "OK, cross-test-server produced some output"
else
  echo "cross-test-server produced no output" >&2
  failed=yes
fi

if grep fail "$DBUS_TOP_BUILDDIR"/test/cross-client.log; then
  failed=yes
else
  echo "  - cross-test client reported no failures"
fi

if grep untested "$DBUS_TOP_BUILDDIR"/test/cross-server.log; then
  failed=yes
else
  echo "  - cross-test server reported no untested functions"
fi

echo "==== client log ===="
cat "$DBUS_TOP_BUILDDIR"/test/cross-client.log
echo "==== end ===="

echo "==== server log ===="
cat "$DBUS_TOP_BUILDDIR"/test/cross-server.log
echo "==== end ===="

rm -f "$DBUS_TOP_BUILDDIR"/test/test-service.log
rm -f "$DBUS_TOP_BUILDDIR"/test/cross-client.log
rm -f "$DBUS_TOP_BUILDDIR"/test/cross-server.log
rm -f "$DBUS_TOP_BUILDDIR"/test/monitor.log

if test -n "$skipped"; then
  exit 77
fi
if test -n "$failed"; then
  exit 1
fi
exit 0
