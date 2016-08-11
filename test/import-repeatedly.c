/* Regression test for https://bugs.freedesktop.org/show_bug.cgi?id=23831 */

#include <stdio.h>
#include <string.h>

#include <Python.h>

int main(void)
{
    int i;

    puts("1..1");

    for (i = 0; i < 100; ++i) {
        Py_Initialize();

        if (PyRun_SimpleString("import dbus\n") != 0) {
            puts("not ok 1 - there was an exception");
            return 1;
        }

        /* This is known not to work in Python 3.6.0a3, for reasons that
         * are not a dbus-python bug. */
        if (strcmp(Py_GetVersion(), "3.6") >= 0) {
            puts("ok 1 # SKIP - http://bugs.python.org/issue27736");
            Py_Finalize();
            return 0;
        }

        Py_Finalize();
    }

    puts("ok 1 - was able to import dbus 100 times");

    return 0;
}
