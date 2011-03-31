#	$LAAS$

#
# Copyright (c) 2002-2003,2008-2011 LAAS/CNRS
# All rights reserved.
#
# Redistribution  and  use in source   and binary forms,  with or without
# modification, are permitted provided that  the following conditions are
# met:
#
#   1. Redistributions  of  source code must  retain  the above copyright
#      notice, this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must  reproduce the above copyright
#      notice,  this list of  conditions and  the following disclaimer in
#      the  documentation   and/or  other  materials   provided with  the
#      distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE  AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY  EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES   OF MERCHANTABILITY AND  FITNESS  FOR  A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO  EVENT SHALL THE AUTHOR OR  CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT,  INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING,  BUT  NOT LIMITED TO, PROCUREMENT  OF
# SUBSTITUTE  GOODS OR SERVICES;  LOSS   OF  USE,  DATA, OR PROFITS;   OR
# BUSINESS  INTERRUPTION) HOWEVER CAUSED AND  ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE  USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#                                       Anthony Mallet on Fri Mar 15 2002
#

dnl --- Compute CFLAGS --------------------------------------------------

AC_DEFUN([ROBOT_CFLAGS],
[
   C_DEBUG_FLAGS=-g

   if test x"${GCC}" = xyes; then
      C_OPTIMIZE_FLAGS=-O2
      C_WARNING_FLAGS="-Wall -Werror -Wno-unknown-pragmas"
   fi
])


dnl --- Test that CPP accepts '-' as a file name ------------------------

AC_DEFUN([ROBOT_CPP_USES_STDIN],
[
   AC_REQUIRE_CPP()

   AC_CACHE_CHECK(
      [whether ${CPP} accepts files on standard input],
      ac_cv_robot_cpp_stdin,
      [
         if echo TEST | ${CPP} - -DTEST=yes 2>&1 | grep yes >/dev/null; then
            ac_cv_robot_cpp_stdin=yes;
         else
            ac_cv_robot_cpp_stdin=no;
         fi
      ])

   if test x"${ac_cv_robot_cpp_stdin}" = xno; then
      AC_MSG_ERROR([The cpp program doesn't accept files on stdin])
   fi
])


dnl --- Look for the laas mkdep executable ------------------------------

AC_DEFUN([ROBOT_PROG_MKDEP],
[
   AC_CACHE_CHECK([for LAAS mkdep], ac_cv_robot_mkdep,
    [
	IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS=":"
        ac_cv_robot_mkdep=no
        ac_tmppath="$exec_prefix/bin:$prefix/bin:$PATH"
        for ac_dir in $ac_tmppath; do
            test -z "$ac_dir" && ac_dir=.
            if eval test -x $ac_dir/mkdep; then
	       echo > conftest.h
	       echo '#include "conftest.h"' > conftest.c
	       if $ac_dir/mkdep -c $CC -o conftest.mkdep 1>/dev/null 2>&1; then
		  if test -f conftest.mkdep; then
		     eval ac_cv_robot_mkdep="$ac_dir/mkdep"
                     break
		  fi
	       fi

            fi
	done
	IFS="$ac_save_ifs"
    ])

    if test x"$ac_cv_robot_mkdep" = xno; then
	AC_SUBST(MKDEP, :)
    else
	AC_SUBST(MKDEP, $ac_cv_robot_mkdep)
    fi
])


dnl --- Check for ar -----------------------------------------------------

AC_DEFUN([ROBOT_PROG_AR],
[
   AC_CHECK_PROG(AR, ar, ar)
   if test x"${AR}" = x; then
      AC_MSG_ERROR([ar not found])
   fi
])


dnl --- Look for includes in a path ------------------------------------
dnl ROBOT_PATH_INC(PACKAGE, VARIABLE, INC, [, VALUE-IF-NOT-FOUND, [, PATH]])
dnl
AC_DEFUN([ROBOT_PATH_INC],
[
   AC_ARG_WITH($1-includes,
	       AC_HELP_STRING([--with-$1-includes=DIR],
        		      [$1 includes are in DIR]),
               opt_pathinc_$2=$withval)
   AC_MSG_CHECKING([for $3 includes])
   AC_CACHE_VAL(ac_cv_path_$2,
    [
	IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS=":"
        ac_tmppath="[$]opt_pathinc_$2:$5"
        for ac_dir in $ac_tmppath; do
            test -z "$ac_dir" && ac_dir=.
            if eval test -f $ac_dir/$3; then
               eval ac_cv_path_$2="$ac_dir"
               break
            fi
	done
	IFS="$ac_save_ifs"
    ])
   $2="$ac_cv_path_$2"
   if test -n "[$]$2"; then
      AC_MSG_RESULT([$]$2)
   else
      AC_MSG_RESULT(no)
      ifelse([$4], , , $4)
   fi
   AC_SUBST($2)
])


dnl --- Look for a library in a path ------------------------------------
dnl ROBOT_PATH_LIB(PACKAGE, VARIABLE, LIB, [, VALUE-IF-NOT-FOUND, [, PATH]])
dnl
AC_DEFUN([ROBOT_PATH_LIB],
[
   AC_ARG_WITH($1-libraries,
	       AC_HELP_STRING([--with-$1-libraries=DIR],
        		      [$1 libraries are in DIR]),
               opt_pathlib_$2=$withval)

   AC_MSG_CHECKING([for $3 librairies])
   AC_CACHE_VAL(ac_cv_path_$2,
    [
	IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS=":"
        ac_tmppath="[$]opt_pathlib_$2:$5"
        for ac_dir in $ac_tmppath; do
            test -z "$ac_dir" && ac_dir=.
            if eval test -f $ac_dir/$3.a; then
               eval ac_cv_path_$2="$ac_dir"
               break
            fi
            if eval test -f $ac_dir/$3.so; then
               eval ac_cv_path_$2="$ac_dir"
               break
            fi
	done
	IFS="$ac_save_ifs"
    ])
   $2="$ac_cv_path_$2"
   if test -n "[$]$2"; then
      AC_MSG_RESULT([$]$2)
   else
      AC_MSG_RESULT(no)
      ifelse([$4], , , $4)
   fi
   AC_SUBST($2)
])


dnl --- Look for a file in a path ---------------------------------------
dnl ROBOT_PATH_FILE(PACKAGE, VARIABLE, LIB, [, VALUE-IF-NOT-FOUND, [, PATH]])
dnl
AC_DEFUN([ROBOT_PATH_FILE],
[
   AC_ARG_WITH($1,
	       AC_HELP_STRING([--with-$1=DIR],
        		      [$1 is in DIR]),
               opt_pathlib_$2=$withval)

   AC_MSG_CHECKING([for $1 files])
   AC_CACHE_VAL(ac_cv_path_$2,
    [
	IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS=":"
        ac_tmppath="[$]opt_pathlib_$2:$5"
        for ac_dir in $ac_tmppath; do
            test -z "$ac_dir" && ac_dir=.
            if eval test -f $ac_dir/$3; then
               eval ac_cv_path_$2="$ac_dir"
               break
            fi
	done
	IFS="$ac_save_ifs"
    ])
   $2="$ac_cv_path_$2"
   if test -n "[$]$2"; then
      AC_MSG_RESULT([$]$2)
   else
      AC_MSG_RESULT(no)
      ifelse([$4], , , $4)
   fi
   AC_SUBST($2)
])


dnl --- Look for tcl ----------------------------------------------------
dnl
dnl
AC_DEFUN([ROBOT_LIB_TCL],
[
   AC_ARG_WITH(tcl,
      [  --with-tcl=DIR          directory containing tclConfig.sh],
      [tcl_prefix=$withval],
      [for ac_dir in \
         ${exec_prefix}/lib      \
	 /Library/Frameworks/Tcl.framework \
	 /System/Library/Frameworks/Tcl.framework \
         /usr/local/lib/tcl8.[[0-9]]	\
         /usr/local/lib          \
         /usr/pkg/lib            \
         /usr/lib/tcl8.[[0-9]]	 \
         /usr/lib                \
        ; \
       do
         if test -r "$ac_dir/tclConfig.sh"; then
            tcl_prefix=$ac_dir
            break
         fi
       done])

   AC_MSG_CHECKING([for tclConfig.sh])
   if test -r "${tcl_prefix}/tclConfig.sh"; then
      file=${tcl_prefix}/tclConfig.sh
      . $file
      AC_MSG_RESULT([${tcl_prefix}/tclConfig.sh])
   else
      AC_MSG_RESULT([not found (fatal)])
      AC_MSG_RESULT([Please use --with-tcl to specify a valid path to your tclConfig.sh file])
      exit 2;
   fi
   dnl substitute variables in TCL_LIB_SPEC
   eval TCL_LIB_SPEC="\"${TCL_LIB_SPEC}\""

   AC_MSG_CHECKING([for tcl headers])
   test -z "$tcl_test_include" && tcl_test_include=tcl.h
   AC_LANG([C])
   ac_tmp_cppflags=$CPPFLAGS; CPPFLAGS="${CPPFLAGS} ${TCL_INCLUDE_SPEC}"
   AC_TRY_COMPILE([#include "$tcl_test_include"], [],[
      AC_MSG_RESULT([${TCL_INCLUDE_SPEC}])
   ],[
      AC_MSG_RESULT([Not found (fatal)])
      AC_MSG_ERROR([tcl headers seem not to be installed.])
   ])
   CPPFLAGS=$ac_tmp_cppflags


   AC_MSG_CHECKING([for tcl library])
   AC_LANG([C])
   ac_tmp_cppflags=$CPPFLAGS; CPPFLAGS="${CPPFLAGS} ${TCL_INCLUDE_SPEC}"
   ac_tmp_ldflags=$LDFLAGS; LDFLAGS="${LDFLAGS} ${TCL_LIB_SPEC}"
   AC_TRY_LINK([#include "$tcl_test_include"], [Tcl_Interp *i; Tcl_Init(i);],[
      AC_MSG_RESULT([${TCL_LIB_SPEC}])
   ],[
      AC_MSG_RESULT([Not found (fatal)])
      AC_MSG_ERROR([tcl libraries seem not to be installed or cannot be linked.])
   ])
   CPPFLAGS=$ac_tmp_cppflags
   LDFLAGS=$ac_tmp_ldflags

   # Add libtool -R flag to the runtime path of tcl
   AC_PROG_SED
   LIB_RUNTIME_DIR=`echo $TCL_LIB_SPEC | \
	${SED} -ne 's|.*-L[[ 	]]*\([[^ 	]]*\).*|\1|p'`
   case "$LIB_RUNTIME_DIR" in
	"") ;;
	/usr/lib) ;;
	*)
	   TCL_LIB_SPEC="-R${LIB_RUNTIME_DIR} ${TCL_LIB_SPEC}"
	   ;;
   esac

   # stubs library for the extension
   if test "$TCL_SUPPORTS_STUBS" = "1"; then
      TCL_STUB_CPPFLAGS=-DUSE_TCL_STUBS
   else
      TCL_STUB_LIB_SPEC=$TCL_LIB_SPEC
   fi

   AC_SUBST(TCL_INCLUDE_SPEC)
   AC_SUBST(TCL_LIBS)
   AC_SUBST(TCL_LIB_FLAG)
   AC_SUBST(TCL_LIB_SPEC)
   AC_SUBST(TCL_DBGX)
   AC_SUBST(TCL_STUB_CPPFLAGS)
   AC_SUBST(TCL_STUB_LIB_SPEC)
   AC_SUBST(TCL_STUB_LIB_SPEC)
])


dnl --- Look for tk -----------------------------------------------------
dnl
dnl
AC_DEFUN([ROBOT_LIB_TK],
[
   AC_ARG_WITH(tk,
      [  --with-tk=DIR           directory containing tkConfig.sh],
      [tk_prefix=$withval],
      [for ac_dir in \
         ${tcl_prefix}                   \
         ${exec_prefix}/lib              \
	 /Library/Frameworks/Tk.framework \
	 /System/Library/Frameworks/Tk.framework \
         /usr/local/lib/tk$TCL_VERSION   \
         /usr/local/lib                  \
         /usr/pkg/lib                    \
         /usr/lib/tk$TCL_VERSION	 \
         /usr/lib                        \
         ; \
       do
          if test -r "$ac_dir/tkConfig.sh"; then
             tk_prefix=$ac_dir
             break
          fi
       done])

   if test "x${tk_prefix}" = "xno"; then
	HAS_TK=no
   else

   file=${tk_prefix}/tkConfig.sh
   . $file
   dnl substitute variables in TK_LIB_SPEC
   eval TK_INCLUDE_SPEC="\"${TK_INCLUDE_SPEC} ${TK_XINCLUDES}\""

   AC_MSG_CHECKING([for tk headers])
   test -z "$tk_test_include" && tk_test_include=tk.h
   AC_LANG([C])
   ac_tmp_cppflags=$CPPFLAGS;
   CPPFLAGS="${CPPFLAGS} ${TK_INCLUDE_SPEC} ${TCL_INCLUDE_SPEC}"
   AC_TRY_COMPILE([#include "$tk_test_include"], [],[
      AC_MSG_RESULT([${TK_INCLUDE_SPEC}])
   ],[
      AC_MSG_RESULT([Not found (fatal)])
      AC_MSG_ERROR([tk headers seem not to be installed.])
   ])
   CPPFLAGS=$ac_tmp_cppflags


   AC_MSG_CHECKING([for tk library])
   AC_LANG([C])
   ac_tmp_cppflags=$CPPFLAGS;
   ac_tmp_ldflags=$LDFLAGS;
   CPPFLAGS="${CPPFLAGS} ${TK_INCLUDE_SPEC} ${TCL_INCLUDE_SPEC}"
   LDFLAGS="${LDFLAGS} ${TK_LIB_SPEC} ${TCL_LIB_SPEC}"
   AC_TRY_LINK([#include "$tk_test_include"], [Tcl_Interp *i; Tk_Init(i);],[
      AC_MSG_RESULT([${TK_LIB_SPEC}])
   ],[
      AC_MSG_RESULT([Not found (fatal)])
      AC_MSG_ERROR([tk libraries seem not to be installed or cannot be linked.])
   ])
   CPPFLAGS=$ac_tmp_cppflags
   LDFLAGS=$ac_tmp_ldflags

   # Add libtool -R flag to the runtime path of tcl
   AC_PROG_SED
   LIB_RUNTIME_DIR=`echo $TK_LIB_SPEC | \
	${SED} -ne 's|.*-L[[ 	]]*\([[^ 	]]*\).*|\1|p'`
   case "$LIB_RUNTIME_DIR" in
	"") ;;
	/usr/lib) ;;
	*)
	   TK_LIB_SPEC="-R${LIB_RUNTIME_DIR} ${TK_LIB_SPEC}"
	   ;;
   esac

   HAS_TK=yes

   fi # --with-tk=no

   AC_SUBST(HAS_TK)
   AC_SUBST(TK_INCLUDE_SPEC)
   AC_SUBST(TK_LIBS)
   AC_SUBST(TK_LIB_FLAG)
   AC_SUBST(TK_LIB_SPEC)
])
