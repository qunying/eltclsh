dnl $LAAS$
dnl
dnl configure.in --
dnl	process this file with autoconf to produce a configure script.
dnl

AC_REVISION($LAAS$)

AC_INIT([eltclsh],[1.6],[openrobots@laas.fr])
AC_PREREQ(2.59)

AC_CONFIG_HEADER(config.h)

AC_CANONICAL_HOST

dnl --- config.h stuff --------------------------------------------------
dnl
AH_TOP([
/*	$]LAAS[: $ */
#ifndef H_ELTCLSH_CONFIG
#define H_ELTCLSH_CONFIG
])

AH_BOTTOM([
#endif /* H_ELTCLSH_CONFIG */
])


dnl --- name of the interpreters ----------------------------------------
ELTCLSH=eltclsh
ELWISH=elwish
AC_SUBST(ELTCLSH)
AC_SUBST(ELWISH)


dnl Checks for headers --------------------------------------------------
dnl
AC_CHECK_HEADERS(sys/cdefs.h)


dnl --- checks for programs ---------------------------------------------
dnl
AC_DISABLE_SHARED
AC_PROG_LIBTOOL
AC_SUBST(LIBTOOL_DEPS)

AC_PROG_MAKE_SET
AC_PROG_CC
AC_CHECK_PROGS(GROFF, groff)

ROBOT_CFLAGS

ROBOT_PROG_MKDEP


dnl try to find an eltclsh for the host machine
if test "x${cross_compiling}" = "xyes"; then
   AC_PATH_PROG(HOST_ELTCLSH, eltclsh, [:],	${PATH})
else
   HOST_ELTCLSH=
fi
AC_SUBST(HOST_ELTCLSH)


dnl --- checks for typedefs ---------------------------------------------
dnl
AC_TYPE_SIGNAL


dnl --- check for extra includes or lib dirs ----------------------------
dnl
withval=""
AC_ARG_WITH(includes,
	[  --with-includes=DIR     search include DIR for optional packages])
for ac_dir in NONE $withval ; do\
   if test "x$ac_dir" != "xNONE"; then
	if test ! -d $ac_dir; then
		AC_MSG_RESULT([Warning: directory $ac_dir does not exist])
	else
		AC_MSG_RESULT([adding $ac_dir to include search path])
		extra_include="$extra_include $ac_dir"
	fi
   fi
done

withval=""
AC_ARG_WITH(libraries,
	[  --with-libraries=DIR    search library DIR for optional packages])
for ac_dir in NONE $withval ; do \
   if test "x$ac_dir" != "xNONE"; then
	if test ! -d $ac_dir; then
		AC_MSG_RESULT([Warning: directory $ac_dir does not exist])
	else
		AC_MSG_RESULT([adding $ac_dir to library search path])
		extra_lib="$extra_lib $ac_dir"
	fi
   fi
done


dnl --- checks for libraries --------------------------------------------
dnl
AC_PATH_XTRA
ROBOT_LIB_TCL
ROBOT_LIB_TK

AC_SEARCH_LIBS([tputs], [termcap ncurses])

dnl libedit
AC_LANG_C
ac_tmp_cppflags=$CPPFLAGS
ac_tmp_ldflags=$LDFLAGS
ac_tmp_libs=$LIBS

AC_MSG_CHECKING([for libedit headers])

AC_TRY_LINK([#include <histedit.h>], [int a = EL_GETCFN],
[
  AC_MSG_RESULT([found])
  EL_CPPFLAGS=
],
[
  for ac_dir in \
	$prefix/include		\
	$extra_include		\
	/usr/local/include	\
	/usr/include		\
	; \
  do
  if test -r "$ac_dir/histedit.h"; then
    CPPFLAGS="${ac_tmp_cppflags} -I$ac_dir"
    AC_TRY_LINK([#include <histedit.h>], [int a = EL_GETCFN], [], [continue])
    ac_edit_header=$ac_dir
    break
  fi
  done
  if test "x$ac_edit_header" = "x"; then
    AC_MSG_RESULT([not found (fatal)])
    AC_MSG_RESULT([Please use --with-includes to specify a valid path to your libedit headers]) 
    AC_MSG_RESULT([Also, make sure you have the EL_GETCFN function.]) 
    exit 2;
  fi
  AC_MSG_RESULT([$ac_edit_header])
  EL_CPPFLAGS="-I$ac_edit_header"
])

AC_MSG_CHECKING([for libedit library])

AC_TRY_LINK([#include <histedit.h>], [el_set(0, EL_GETCFN)],
[
  AC_MSG_RESULT([found])
  EL_LIB_SPEC="-ledit $LIBS"
],
[
  for ac_dir in \
	$exec_prefix/lib	\
	$prefix/lib		\
	$extra_lib		\
	/usr/local/lib		\
	/usr/lib		\
	; \
  do
  if test -d $ac_dir; then
    LDFLAGS="-L$ac_dir ${ac_tmp_ldflags}"
    LIBS="-ledit ${ac_tmp_libs}"
    AC_TRY_LINK([#include <histedit.h>], [el_set(0, EL_GETCFN)],
		[], [continue])
    ac_edit_lib=$ac_dir
    break
  fi
  done
  if test "x$ac_edit_lib" = "x"; then
    AC_MSG_RESULT([not found (fatal)])
    AC_MSG_ERROR([Please use --with-libs to specify a valid path to your libedit library], 2) 
  fi
  AC_MSG_RESULT([$ac_edit_lib])

  EL_LIB_SPEC="-L$ac_edit_lib -ledit ${ac_tmp_libs}"
])

CPPFLAGS="$ac_tmp_cppflags"
LDFLAGS="$ac_tmp_ldflags"
LIBS="$ac_tmp_libs"

AC_SUBST(EL_CPPFLAGS)
AC_SUBST(EL_LIB_SPEC)

dnl --- create the Makefiles --------------------------------------------
dnl
CFLAGS="${C_DEBUG_FLAGS} ${C_WARNING_FLAGS}"

AC_OUTPUT(config.mk Makefile src/Makefile tcl/Makefile)
