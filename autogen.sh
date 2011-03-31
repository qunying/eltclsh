#! /bin/sh
aclocal -I m4 || exit 1
libtoolize -cf
autoconf

