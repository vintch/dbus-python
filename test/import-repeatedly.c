/* Regression test for https://bugs.freedesktop.org/show_bug.cgi?id=23831 */

#include <stdio.h>

#include <Python.h>

int main(void)
{
    int i;

    puts("1..1");

    for (i = 0; i < 100; ++i) {
        Py_Initialize();
        PyRun_SimpleString("import dbus\n");
        Py_Finalize();
    }

    puts("ok 1 - was able to import dbus 100 times");

    return 0;
}
