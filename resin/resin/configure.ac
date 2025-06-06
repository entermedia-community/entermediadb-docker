AC_INIT([resin],4.0.56)
AC_CONFIG_AUX_DIR(automake)
#AC_CONFIG_MACRO_DIR([m4])


dnl Get os info
AC_CANONICAL_SYSTEM

AM_INIT_AUTOMAKE
AC_PREFIX_DEFAULT(/usr/local/share)

FULL_VERSION="Resin $PACKAGE_VERSION -- `date`"
AC_SUBST(FULL_VERSION)

dnl Checks for programs.
AC_PROG_CC
AC_PROG_LD
AC_PROG_EGREP

dnl Checks for poll.h
#AC_CHECK_HEADER(sys/poll.h, [ CFLAGS="$CFLAGS -DPOLL"; poll=1 ])
AC_CHECK_HEADER(sys/poll.h, [ poll=1 ])
dnl Checks for epoll.h
AC_CHECK_HEADER(sys/epoll.h, [ CFLAGS="$CFLAGS -DEPOLL"; epoll=1 ])

#
# Resin home
#

resin_version="resin-$PACKAGE_VERSION"

if test "$prefix" == "NONE"; then
  usr_share="$ac_default_prefix"
  resin_home="$ac_default_prefix/$resin_version"
else
  resin_home="$prefix"
fi

build_dir="${abs_builddir}"

if test -z "${build_dir}"; then
  build_dir=`pwd`
fi

AC_SUBST(resin_home)
AC_SUBST(resin_version)
AC_SUBST(usr_share)
AC_SUBST(build_dir)
AC_SUBST(initd_dir)

#
# --with-resin-root
#

AC_ARG_WITH(resin-root,
[AS_HELP_STRING([--with-resin-root=DIR],
                [resin data directory])],
[resin_root=${withval}])

if test -z "$resin_root"; then
  if test "$prefix" == "NONE"; then
    resin_root="/var/resin"
  else
    resin_root="$prefix"
  fi
fi

AC_SUBST(resin_root)

#
# --with-resin-conf
#
AC_SUBST(resin_conf)

AC_ARG_WITH(resin-conf,
[AS_HELP_STRING([--with-resin-conf=DIR],
                [resin configuration directory])],
[resin_conf=${withval}])

if test -z "$resin_conf"; then
  if test "$prefix" == "NONE"; then
    resin_conf="/etc/resin"
  else
    resin_conf="$prefix/conf"
  fi
fi

#
# --with-resin-log
#
AC_SUBST(resin_log)

AC_ARG_WITH(resin-log,
[AS_HELP_STRING([--with-resin-log=DIR],
                [resin log directory])],
[resin_log=${withval}])

if test -z "$resin_log"; then
  if test "$prefix" == "NONE"; then
    resin_log="/var/log/resin"
  else
    resin_log="$prefix/log"
  fi
fi

#
# --with-resin-init.d
#
if test -d "/etc/init.d/rc.d"; then
  resin_init_d="/etc/init.d/rc.d/resin"
  initd_dir="/etc/init.d/rc.d"
elif test -d "/etc/init.d"; then
  resin_init_d="/etc/init.d/resin"
  initd_dir="/etc/init.d"
elif test -d "/etc/rc.d"; then
  resin_init_d="/etc/rc.d"
  initd_dir="/etc/"
fi

AC_ARG_WITH(resin-init-d,
[AS_HELP_STRING([--with-resin-init-d=PATH],
                [resin startup (init.d) script path])],
[
case "${withval}" in
  no)  
    resin_init_d=
    initd_dir= 
    ;;
  *)
    resin_init_d=${withval}
    initd_dir=`dirname $resin_init_d`
    ;;
esac
])

AC_SUBST(resin_init_d)
AC_SUBST(initd_dir)

resin_pro="."
resin_os="../resin_os"
is_dev=""

if test -r "modules/c/src/resin/mmap_file.c"; then
  resin_pro="."
elif test -r "../pro/modules/c/src/resin/mmap_file.c"; then
  resin_pro="../pro"
  resin_os="../../../../../resin/modules/c/src/resin_os"
  is_dev="true"
fi

AC_SUBST(resin_os)
AC_SUBST(resin_pro)

#
# --with-java-home
#
AC_ARG_WITH(java-home,
[AS_HELP_STRING([--with-java-home=DIR],
                [java home])],
[JAVA_HOME=${withval}])

if test -n "$JAVA_HOME"; then
  JAVA_EXE="$JAVA_HOME/bin/java"
elif test -x "/usr/libexec/java_home"; then
  JAVA_HOME=`/usr/libexec/java_home`
else
  java=`which java 2>/dev/null`
  if test -x "$java"; then
    while test -h "$java"
    do
      head=`dirname $java`
      tail=`/bin/ls -l $java | awk '{ print $NF; }'`
      if test -f "$tail"; then
        java=$tail
      else
        java=$head/$tail
      fi
    done

    JAVA_BIN=`dirname $java`

    # we're in $JAVA_HOME/jre
    if test -f "$JAVA_BIN/include/jni.h"; then
      JAVA_HOME="$JAVA_BIN"
    elif test -f "$JAVA_BIN/../include/jni.h"; then
      JAVA_HOME="$JAVA_BIN/.."
    elif test -f "$JAVA_BIN/../../include/jni.h"; then
      JAVA_HOME="$JAVA_BIN/../.."
    elif test -f "/System/Library/Frameworks/JavaVM.framework"; then
      JAVA_HOME="/System/Library/Frameworks/JavaVM.framework"
    elif test -d "/etc/alternatives/java_sdk"; then
      JAVA_HOME="/etc/alternatives/java_sdk"
    elif test -f "$JAVA_BIN/lib/rt.jar"; then
      JAVA_HOME=`cd $JAVA_BIN/..; pwd`
    elif test -f "/usr/lib/jvm/java-6-openjdk/include/jni.h"; then
      JAVA_HOME="/usr/lib/jvm/java-6-openjdk"
    elif test -f "/usr/lib/jvm/java-6-sun/include/jni.h"; then
      JAVA_HOME="/usr/lib/jvm/java-6-sun"
    elif test -f "/usr/lib/jvm/java-openjdk/include/jni.h"; then
      JAVA_HOME="/usr/lib/jvm/java-openjdk"
    elif test -f "/usr/lib/jvm/java/include/jni.h"; then
      JAVA_HOME="/usr/lib/jvm/java"
    elif test -d "/usr/java"; then
      JAVA_HOME=/usr/java
    else
      JAVA_HOME="$JAVA_BIN"
    fi
  elif test -d "/usr/java"; then
    JAVA_HOME=/usr/java
  elif test -f "/System/Library/Frameworks/JavaVM.framework"; then
    JAVA_HOME="/System/Library/Frameworks/JavaVM.framework"
  fi
fi

echo $ac_n "checking for JAVA_HOME... $JAVA_HOME"

if test ! -d "$JAVA_HOME"; then
  AC_MSG_ERROR([Can't find valid JAVA_HOME ${JAVA_HOME}])
fi

AC_SUBST(JAVA_HOME)

if test -z "$JAVA_EXE"; then
  java=`which java 2>/dev/null`
  if test -x "$java"; then
    JAVA_EXE="$java"
  fi
fi

if test -z "$JAVA_EXE"; then
  JAVA_EXE="$JAVA_HOME/bin/java"
fi

AC_SUBST(JAVA_EXE)

JAVA_ARGS=

$JAVA_EXE -d64 -version 1>/dev/null 2>/dev/null
if test $? = "0"; then
  JAVA_ARGS="-d64"
fi

AC_SUBST(JAVA_ARGS)

#
# libtool stuff
#
AC_PROG_LIBTOOL
if test -z "${LTFLAGS}"; then
  LTFLAGS="--silent"
fi

LIBTOOL_SCRIPT="`pwd`/libtool"
LIBTOOL="${LIBTOOL_SCRIPT} ${LTFLAGS}"
SH_LIBTOOL="${SHELL} ${LIBTOOL_SCRIPT} ${LTFLAGS}"
SHLTCFLAGS=""
LTCFLAGS=""

AC_SUBST(LTFLAGS)
AC_SUBST(LIBTOOL_SCRIPT)
AC_SUBST(LIBTOOL)
AC_SUBST(SH_LIBTOOL)
AC_SUBST(LTCFLAGS)
AC_SUBST(EGREP)

INCLUDES=""
plugins=common
LIBEXEC=libexec

AC_SUBST(plugins)
AC_SUBST(resin_pro_plugins)
AC_SUBST(LIBEXEC)
dnl should be unnecessary
AC_SUBST(LD)

ACLOCAL=aclocal
AUTOMAKE=automake
AC_SUBST(ACLOCAL)
AC_SUBST(AUTOMAKE)

#
# additional CFLAGS
#
# for solaris
CFLAGS="$CFLAGS -D_POSIX_PTHREAD_SEMANTICS"

#
# --with-apache-src
#
AC_ARG_WITH(apache-src,
[AS_HELP_STRING([--with-apache-src=DIR],
                [Apache src static compilation])],
[
apache_src=${withval}

if test -d "${apache_src}/modules"; then
  a=b
elif test -d "${apache_src}/src/modules"; then
  apache_src=${apache_src}/src
else
  AC_MSG_ERROR([Can't find valid Apache source ${apache_src}])
fi

echo "using Apache source in ${apache_src}"
])
#
# --with-apache
#
AC_ARG_WITH(apache,
[AS_HELP_STRING([--with-apache=DIR],
                [the Apache root directory])],
[
apache_dir=${withval}

if test "${apache_dir}" = "yes"; then
  if test -d /usr/local/apache; then
    apache_dir=/usr/local/apache
  else
    apxs=`which apxs2`
  fi
fi

if test ! -d "${apache_dir}" -a ! -x "${apxs}"; then
  AC_MSG_ERROR([--with-apache=${apache_dir} is not a valid Apache directory])
fi

apache=1
])

#
# --with-apxs
#
AC_ARG_WITH(apxs,
[AS_HELP_STRING([--with-apxs=PATH],
                [the Apache configuration utility])],
[
apxs=${withval}

if test "${apxs}" = "yes"; then

  apxs=`which apxs2` 2>/dev/null
  if test -z "$apxs"; then
    apxs=`which apxs` 2>/dev/null
  fi

  if test -z "$apxs"; then
    apxs=apxs2
  fi
  
  if test ! -x "$apxs"; then
    AC_ERROR("'$apxs' is not a valid apxs")
  fi   

fi

apache=1
])

#
# --with-apache-eapi
#
AC_ARG_WITH(apache-eapi,
[AS_HELP_STRING([--with-apache-eapi=DIR],
                [Apache eapi support])],
[apache_eapi=${withval}])

#
# --with-apache-include
#
AC_ARG_WITH(apache-include,
[AS_HELP_STRING([--with-apache-include=DIR],
                [the Apache include directory])],
[
apache_include=${withval}

if test "${apache_include}" = "yes"; then
    apache_include=
fi

apache=1
])

#
# --with-apache-libexec
#
AC_ARG_WITH(apache-libexec,
[AS_HELP_STRING([--with-apache-libexec=DIR],
                [the Apache module directory])],
[
apache_libexec=${withval}

if test "${apache_libexec}" = "yes"; then
    apache_libexec=
fi

apache=1
])

#
# --with-apache-conf
#
AC_ARG_WITH(apache-conf,
[AS_HELP_STRING([--with-apache-conf=DIR],
                [the Apache configuration])],
[
apache_conf=${withval}

if test "${apache_conf}" = "yes"; then
    apache_conf=
fi

apache=1
])

apache_cflags=

#
# --with-apache-cflags
#
AC_ARG_WITH(apache-cflags,
[AS_HELP_STRING([--with-apache-cflags=flags],
                [flags for compiling mod_caucho])],
[
apache_cflags=${withval}

apache=1
])

#
# check that apxs is okay
#
if test -n "${apxs}"; then
  ${apxs} -q PREFIX >/dev/null 2>/dev/null
  if test "$?" -ne 0; then
    AC_MSG_ERROR(Apache ${apxs} is not a valid apxs script)
  fi
elif test -x "${apache_bin}/apxs"; then
  apxs=${apache_bin}/apxs
elif test -x "${apache_dir}/bin/apxs"; then
  apxs=${apache_dir}/bin/apxs
elif test -x "${apache_dir}/sbin/apxs"; then
  apxs=${apache_dir}/sbin/apxs
elif test -x "/sbin/apxs"; then
  apxs=/sbin/apxs
elif test -x "/usr/sbin/apxs"; then
  apxs=/usr/sbin/apxs
fi

#
# heuristics for finding the Apache include directory
#
if test -z "${apache_include}" -a -n "${apxs}"; then
  APACHE_INC=`${apxs} -q EXTRA_INCLUDES`

  if test -x "${APACHE_INC}"; then
    apache_include=`${apxs} -q INCLUDEDIR`
  fi
fi

if test -z "${apache_include}" -a -r "${apache_dir}/include/httpd.h"; then
  apache_include=${apache_dir}/include
fi

if test -z "${APACHE_INC}" -a -n "${apache_include}"; then
  APACHE_INC="-I${apache_include}"
fi

#
# deal with stronghold
#
if test -z ${APACHE_INC} -a -z "${apache_include}" -a -r "${apache_dir}/src/include/httpd.h"; then
  apache_include=${apache_dir}/src/include

  APACHE_INC="-I${apache_dir}/src/include"
  APACHE_INC="-I${apache_dir}/ssl/include $APACHE_INC"
  APACHE_INC="-I${apache_dir}/src/os/unix $APACHE_INC"
fi

if test -n "$apache" -a -z "${APACHE_INC}" -a ! -r ${apache_include}/httpd.h; then
  AC_MSG_ERROR([Can't find Apache include directory ${apache_include}])
fi

#
# heuristics for finding the Apache bin directory
#
if test -n "${apache_bin}"; then
  a=b
elif test -x "${apxs}"; then
  apache_bin=`${apxs} -q SBINDIR`
  apache_exe="${apache_bin}/`${apxs} -q TARGET`"
elif test -n "${apache_dir}"; then
  apache_bin="${apache_dir}/bin"
fi

if test -n "${apache_exe}"; then
 a=b;
elif test -z "${apache_bin}"; then
 a=b;
elif test -x "${apache_bin}/httpd"; then
 apache_exe="${apache_bin}/httpd"
elif test -x "${apache_bin}/apache"; then
 apache_exe="${apache_bin}/apache"
elif test -x "${apache_bin}/httpd2"; then
 apache_exe="${apache_bin}/httpd2"
elif test -x "${apache_bin}/apache2"; then
 apache_exe="${apache_bin}/apache2"
fi

if test -n "${apache_exe}" -a ! -x "${apache_exe}"; then
  AC_MSG_ERROR([Can't find Apache binary in directory ${apache_exe}])
fi

#
# heuristics for finding the Apache module directory
#
if test -z "${apache_libexec}" -a -n "${apxs}"; then
  apache_libexec=`${apxs} -q LIBEXECDIR`
fi

if test -z "${apache_libexec}" -a -d "${apache_dir}/libexec"; then
  apache_libexec=${apache_dir}/libexec
fi

if test -z "${apache_libexec}" -a -d "${apache_dir}/modules"; then
  apache_libexec=${apache_dir}/modules
fi

if test -n "$apache" -a ! -d "${apache_libexec}"; then
  AC_MSG_ERROR([Can't find Apache module directory ${apache_libexec}])
fi

#
# Heuristics for finding the Apache configuration directory
#

if test -z "${apache_conf}" -a -n "${apxs}"; then
  apache_confdir=`${apxs} -q SYSCONFDIR`

  if test -r "${apache_confdir}"/httpd.conf; then
    apache_conf=${apache_confdir}/httpd.conf
  elif test -r "${apache_confdir}"/apache.conf; then
    apache_conf=${apache_confdir}/apache.conf
  elif test -r "${apache_confdir}"/apache2.conf; then
    apache_conf=${apache_confdir}/apache2.conf
  elif test -r "${apache_confdir}"/httpsd.conf; then
    apache_conf=${apache_confdir}/httpsd.conf
  fi
fi

if test -z "${apache_conf}" -a -r "${apache_dir}/conf/httpd.conf"; then
  apache_conf=${apache_dir}/conf/httpd.conf
fi

if test -z "${apache_conf}" -a -r "${apache_dir}/etc/httpd.conf"; then
  apache_conf=${apache_dir}/etc/httpd.conf
fi

if test -n "$apache" -a ! -r "${apache_conf}"; then
  AC_MSG_ERROR([Can't find Apache module configuration ${apache_conf}])
fi

#
# check for apr
#
if test -x "${apxs}"; then
   apr_bin=`${apxs} -q APR_BINDIR 2> /dev/null`
   if test -x "${apr_bin}/apr-config"; then
     apr_inc=`"${apr_bin}/apr-config" --includes`
     APACHE_INC="${APACHE_INC} ${apr_inc}"
   elif test -x "${apr_bin}/apr-1-config"; then
     apr_inc=`"${apr_bin}/apr-1-config" --includes`
     APACHE_INC="${APACHE_INC} ${apr_inc}"
   fi
fi

#
# Apache CFLAGS
#

if test -z "$apache_cflags" -a -x "${apxs}"; then
   if test -x "${apr_bin}/apr-config"; then
     apache_cflags="$apache_cflags `${apr_bin}/apr-config --cppflags`"
     apache_cflags="$apache_cflags `${apr_bin}/apr-config --cflags`"
   elif test -x "${apr_bin}/apr-1-config"; then
     apache_cflags="$apache_cflags `${apr_bin}/apr-1-config --cppflags`"
     apache_cflags="$apache_cflags `${apr_bin}/apr-1-config --cflags`"
   else
     apache_cflags="`${apxs} -q CFLAGS`"
   fi
fi

if test -z "$apache_cflags" -a -x "${apache_exe}"; then
   flags=`${apache_exe} -V | grep EAPI`
   if test -n "$flags"; then
     apache_cflags=-DEAPI
   fi
fi

if test -z "$apache_dir" -a -x "${apxs}"; then
   apache_dir=`${apxs} -q PREFIX`
fi

#
# test posix shared memory
#

#
# --enable-mod_caucho_shm
#
AC_ARG_ENABLE(mod_caucho_shm,
[AS_HELP_STRING([--enable-mod_caucho_shm], [Enable shared memory state for mod_caucho])],
[case "${enableval}" in
 yes) mod_caucho_shm=true ;;
 no)  mod_caucho_shm=false ;;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-mod_caucho_shm) ;;
 esac],[])

if test -n "${apache_dir}"; then
if test "${mod_caucho_shm}" == "true"; then

cat >conftest.$ac_ext <<_ACEOF
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

#define SHM_PATH "/mod_caucho_127.1:8080"
int main(int argc, char **argv)
{
  shm_open(SHM_PATH, O_CREAT | O_RDWR, S_IRWXU | S_IRWXG);

  shm_unlink(SHM_PATH);

  return errno;
}
_ACEOF

apache_shm=""

CC_conftest="${CC} -o conftest ${apache_cflags} -lrt conftest.$ac_ext"
$CC_conftest 1>/dev/null 2>/dev/null
if test "$?" != 0; then
  $CC_conftest
  AC_MSG_WARN(Can't compile posix shared memory test.  Check compilation flags: $CC_conftest)
elif ./conftest; then
  apache_shm="-DSHM"
  apache_cflags="$apache_cflags -lrt"
  AC_MSG_RESULT(mod_caucho will use shared between processes srun status)
else
  AC_MSG_WARN(mod_caucho will not use shared between processes srun status)
fi
rm -f conftest conftest.$ac_ext
else
 AC_MSG_WARN(Shared memory for mod_caucho disabled $apache_shm)
fi
fi

#
# test apache 2.4
# request_rec->remote_ip became client_ip
# request_rec->remote_addr became client_addr
#

if test -n "${apache}"; then

cat >conftest.$ac_ext <<_ACEOF
#include "httpd.h"

int main(int argc, char *argv[]) {
  conn_rec *c;
  c = malloc(sizeof(request_rec));
  &c->client_ip;
  &c->client_addr;

  return 0;
}
_ACEOF

apache_24=""

echo $ECHO_N "checking if apache is 2.4 or later... "

CC_conftest="${CC} -o conftest ${APACHE_INC} ${apache_cflags} conftest.$ac_ext"
$CC_conftest 1>/dev/null 2>/dev/null
if test "$?" == 0; then
  apache_24=-DAPACHE_24
  echo "yes";
else
  echo "no";
  $CC_conftest
  AC_MSG_WARN(Can't compile apache 2.4 test. Check compilation flags if apache is 2.4: $CC_conftest)
  AC_MSG_WARN(Assuming lower apache version)
fi
rm -f conftest conftest.$ac_ext
fi

AC_SUBST(APACHE_INC)
AC_SUBST(apache_libexec)
AC_SUBST(apache_conf)
AC_SUBST(apache_dir)
AC_SUBST(apache_cflags)
AC_SUBST(apache_cflags_shlib)
AC_SUBST(apache_ld_shlib)
AC_SUBST(apache_ldflags_shlib)
AC_SUBST(apache_libs_shlib)
AC_SUBST(apache_shm)
AC_SUBST(apache_24)

#
# --with-setuid
#
setuid_user=resin
setuid_group=resin

AC_ARG_WITH(setuid,
[AS_HELP_STRING([--with-setuid=user],
                [configure default setuid user])],
[
setuid_user=${withval} 
setuid_set=true
])

#
# --with-setgid
#

AC_ARG_WITH(setgid,
[AS_HELP_STRING([--with-setgid=group],
                [configure default setgid group])],
[
setuid_group=${withval}; 
setuid_set=true
])

AC_SUBST(setuid_user)
AC_SUBST(setuid_group)
AC_SUBST(setuid_set)

user_add=`which useradd`
group_add=`which groupadd`

AC_SUBST(user_add)
AC_SUBST(group_add)

#
# fill in compilation stuff
#
SO=so

is_gcc=`${CC} -v 2>&1 | grep gcc`
is_gnu_ld=`${LD} -v 2>&1 | grep GNU`

#
# Use apxs if it's available
#
if test -z "${apache_ldflags_shlib}"; then
   if test -x "${apr_bin}/apr-config"; then
     apache_cflags_shlib=`${apr_bin}/apr-config --cflags`
     apache_ldflags_shlib=`${apr_bin}/apr-config --link-ld`
#     apache_ldflags_shlib=`${apr_bin}/apr-config --ldflags`
     apache_libs_shlib=`${apr_bin}/apr-config --libs`
 
   elif test -x "${apr_bin}/apr-1-config"; then
     apache_cflags_shlib=`${apr_bin}/apr-1-config --cflags`
     apache_ldflags_shlib=`${apr_bin}/apr-1-config --link-ld`
#     apache_ldflags_shlib=`${apr_bin}/apr-1-config --ldflags`
     apache_libs_shlib=`${apr_bin}/apr-1-config --libs`
 
   elif test -n "${apxs}"; then
     apache_cflags_shlib=`${apxs} -q CFLAGS_SHLIB`
     apache_ld_shlib=`${apxs} -q LD_SHLIB`
     apache_ldflags_shlib=`${apxs} -q LDFLAGS_SHLIB`
     apache_libs_shlib=`${apxs} -q LIBS_SHLIB`

     echo "Using shared library flags from ${apxs}"
  fi
fi

#
# 64bit heuristics
#
echo $ECHO_N "checking if ${JAVA_EXE} is 64-bit... "

$JAVA_EXE -d64 -version 1>/dev/null 2>/dev/null
if test $? = "0"; then
   b64_jni=true
fi

# Require user to use --enable-64bit if the version is optional in the javac

if test -n "$b64_jni"; then
   echo "yes"
else
   echo "no"
fi

if test -n "$b64_jni" -a -z "$b64"; then
  b64=$b64_jni
fi

#
# --enable-64bit
#
AC_ARG_ENABLE(64bit,
[AS_HELP_STRING([--enable-64bit], [Enable 64 bit])],
[case "${enableval}" in
 yes) b64=true; b64_jni=true ;;
 no)  b64=""; b64_jni="" ;;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-64bit) ;;
 esac],[])

#
# --enable-64bit-jni
#
AC_ARG_ENABLE(64bit-jni,
[AS_HELP_STRING([--enable-64bit-jni], [Enable 64 bit JNI only (not Apache)])],
[case "${enableval}" in
 yes) b64_jni=true ;;
 no)  b64_jni="" ;;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-64bit-jni) ;;
 esac],[])

#
# --enable-64bit-plugin
#
AC_ARG_ENABLE(64bit-plugin,
[AS_HELP_STRING([--enable-64bit-plugin], [Enable 64 bit plugin (Apache) (not JNI)])],
[case "${enableval}" in
 yes) b64=true ;;
 no)  b64="" ;;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-64bit-plugin) ;;
 esac],[])

if test -n "${b64}"; then
   b64_jni=true
fi

if test -n "${b64_jni}"; then
   CFLAGS="$CFLAGS -DB64"
   LIBEXEC=libexec64
fi

#
# --enable-lfs
#
AC_ARG_ENABLE(lfs,
[AS_HELP_STRING([--enable-lfs], [Enable large file source support])],
[case "${enableval}" in
 yes) lfs=true ;;
 no)  lfs="";;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-lfs) ;;
 esac],[])

if test -n "${lfs}"; then
  jni_cflags="$jni_cflags -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64"
fi

#
# fill in based on known configurations
#
if test -z "${jni_ld_shlib}"; then
  jni_ld_shlib=${LD}
  jni_cflags_shlib="-fpic"
  jni_ldflags_shlib="-shared"

  plugin_cflags_shlib=$jni_cflags_shlib
  plugin_ldflags_shlib=$jni_ldflags_shlib

  case "$target_os" in
    linux*)
      jni_ld_shlib=${CC}

      CFLAGS="$CFLAGS -pthread -fPIC -fno-omit-frame-pointer -O2"
      jni_cflags="$jni_cflags -fPIC"
      jni_ldflags_shlib="-shared -fPIC"

      if test -n "$b64_jni"; then
        jni_cflags_jni="$jni_cflags_jni -m64 -fPIC"
        jni_ldflags_shlib="$jni_ldflags_shlib -m64"
      else
        jni_cflags="$jni_cflags -m32"
        jni_ldflags_shlib="$jni_ldflags_shlib -m32"
      fi
      
      plugin_cflags_shlib=$jni_cflags_shlib
      plugin_ldflags_shlib=$jni_ldflags_shlib

      if test -n "$b64"; then
        plugin_cflags_jni="$jni_cflags_jni -m64 -fPIC"
        plugin_ldflags_shlib="$jni_ldflags_shlib -m64"
      else
        plugin_cflags="$jni_cflags -m32"
        plugin_ldflags_shlib="$jni_ldflags_shlib -m32"
      fi
      
      if test "$target_cpu" = "armv6l"; then
        jni_cflags_shlib="-fPIC"
        plugin_cflags_shlib=$jni_cflags_shlib
        jni_ldflags_shlib="-shared -fPIC"
        plugin_ldflags_shlib=$jni_ldflags_shlib
        jni_cflags="-fPIC"
        plugin_cflags=$jni_cflags
      fi
      ;;

    *solaris*)
      jni_ldflags_shlib=""
      plugin_ldflags_shlib=""
      
      if test -n "$is_gcc"; then
        jni_cflags_shlib="-fPIC"
        plugin_cflags_shlib="-fPIC"

        CFLAGS="$CFLAGS -fPIC -fno-omit-frame-pointer"
        jni_cflags="$jni_cflags -fPIC -fno-omit-frame-pointer"
        plugin_cflags_shlib="-fPIC"

        if test -n "$b64"; then
          CFLAGS="$CFLAGS -m64"
          plugin_cflags_shlib="-m64"
          
          case $target_cpu in
            *86*)
              plugin_ldflags_shlib="-m64 -R /usr/sfw/lib/64";;
            *)
              plugin_ldflags_shlib="-m64 -R /usr/sfw/lib/64 -R /usr/local/lib/sparcv9";;
          esac
        fi

        if test -n "${b64_jni}"; then
          jni_cflags="$jni_cflags -m64"
          
          case $target_cpu in
            *86*)
              jni_ldflags_shlib="-m64 -R /usr/sfw/lib/64";;
            *)
              jni_ldflags_shlib="-m64 -R /usr/sfw/lib/64 -R /usr/local/lib/sparcv9";;
          esac
        fi

        jni_ldflags_shlib="$jni_ldflags_shlib -shared"
        plugin_ldflags_shlib="$plugin_ldflags_shlib -shared"
      else
        CFLAGS="-mt -KPIC -xO2"
        jni_cflags_shlib="-mt -KPIC -xO2"
        plugin_cflags_shlib="-mt -KPIC -xO2"

        if test -n "$b64"; then
          CFLAGS="$CFLAGS -m64"
        fi

        if test -n "$b64"; then
          plugin_cflags="$plugin_cflags -m64"
          plugin_ldflags_shlib="$jni_ldflags_shlib -m64 -G -mt -z defs -z text"
          plugin_ldflags_shlib="$jni_ldflags_shlib -R/usr/lib/64:/usr/sfw/lib/64:/usr/local/lib/sparcv9 -YP,/usr/lib/64:/usr/sfw/lib/64:/usr/local/lib/sparcv9"
        fi

        if test -n "$b64_jni"; then
          jni_cflags="$jni_cflags -m64"
          jni_ldflags_shlib="$jni_ldflags_shlib -m64 -G -mt -z defs -z text"
          jni_ldflags_shlib="$jni_ldflags_shlib -R/usr/lib/64:/usr/sfw/lib/64:/usr/local/lib/sparcv9 -YP,/usr/lib/64:/usr/sfw/lib/64:/usr/local/lib/sparcv9"
        fi

        jni_ldflags_shlib="$jni_ldflags_shlib -G -mt -z defs -z text"
        plugin_ldflags_shlib="$plugin_ldflags_shlib -G -mt -z defs -z text"
      fi
      ;;

    darwin*)
      jni_cflags_shlib="-DSHARED_MODULE"
      jni_ld_shlib=${CC}
      jni_ldflags_shlib="-dynamiclib -undefined suppress -flat_namespace"

      plugin_ld_shlib=${jni_ld_shlib}
      plugin_ldflags_shlib=${jni_ldflags_shlib}

      if test -n "$b64"; then
        CFLAGS="$CFLAGS -arch x86_64"
        jni_ldflags_shlib="-arch x86_64 $jni_ldflags_shlib"
        plugin_ldflags_shlib="-arch x86_64 $jni_ldflags_shlib"
      fi
      
      if test -n "$b64_jni"; then
        jni_cflags_jni="$CFLAGS_JNI -m64"
        jni_ldflags_shlib="-arch x86_64 $jni_ldflags_shlib"
      fi
      ;;

    *freebsd*)
      CFLAGS="$CFLAGS -fPIC"
      ;;

    *aix*)
      if test -z "$is_gcc"; then
        jni_cflags_shlib="-bexpall"
      else
        jni_cflags_shlib="-fpic"
      fi
      jni_ldflags_shlib=""
      ;;

    *hpux*)
      if test -z "$is_gcc"; then
        jni_cflags_shlib="+z"
      else
        jni_cflags_shlib="-fpic"
      fi
      jni_ldflags_shlib="-b"
      ;;
  esac

#  case "$target_cpu" in
#    x86_64)
#           if test -z "$b64_jni"; then
#        CFLAGS_JNI="$CFLAGS_JNI -m32"
#        LDFLAGS_SHLIB="$LDFLAGS_SHLIB -m32"
#        fi
# ;;
#  esac
fi

case "$target_os" in
  linux*)
        CFLAGS="$CFLAGS -DHAS_SOCK_TIMEOUT -DHAS_SENDFILE -DHAS_SPLICE"
  ;;
  solaris*)
        CFLAGS="$CFLAGS -DHAS_SOCK_TIMEOUT"
  ;;
  darwin*)
        CFLAGS="$CFLAGS -DHAS_SOCK_TIMEOUT"
        # disable poll on macosx, temporarily
        poll=""
  ;;
esac

if test -n "${poll}"; then
   CFLAGS="$CFLAGS -DPOLL"
fi   

if test -z "$apache"; then
  a=b
elif test -n "${APACHE_INC}" -a -z "${apache_include}"; then
  echo "Using Apache 2.0 configuration ${apache_conf}"
  
  plugins="$plugins apache2"
elif test -r "${apache_include}/apr_thread_mutex.h" -o -n "${apr_inc}"; then
  echo "Using Apache 2.0 configuration ${apache_conf}"

  plugins="$plugins apache2"
else
  AC_MSG_ERROR([Can't find valid Apache directory ${apache_inc}])
fi

if test -z "${apache_ld_shlib}"; then
  apache_ld_shlib=$CC
fi    

#if test -z "${apache_ld_shlib}"; then
#  apache_ld_shlib=$jni_ld_shlib
#fi    

if test -z "${apache_ldflags_shlib}"; then
  apache_cflags_shlib=$plugin_cflags_shlib
  
  if test -n "$(plugin_ld_shlib)"; then
    apache_ld_shlib=$plugin_ld_shlib
  fi

#  apache_ldflags_shlib=$plugin_ldflags_shlib
  apache_libs_shlib=$plugin_libs_shlib
fi    

apache_ldflags_shlib="$apache_ldflags_shlib $plugin_ldflags_shlib"

if test -n "$apache_cflags"; then
  echo "Using Apache CFLAGS: $apache_cflags"
fi

#
# Check if cp accepts -u
#
CP=`which cp`
echo $ECHO_N "checking if $CP accepts -u... "

touch /tmp/cp.test.$$.src
$CP -u /tmp/cp.test.$$.src /tmp/cp.test.$$.dest 1>/dev/null 2>/dev/null
if test $? = "0"; then
  CP_U_FLAG=-u
  AC_SUBST(CP_U_FLAG)
  echo "yes"
else
  echo "no"
fi
rm -f /tmp/cp.test.$$.src /tmp/cp.test.$$.dest

#
# Find bash. FreeBSD has bash in /usr/loca/bin
#
BASH=`which bash`
AC_SUBST(BASH)

#if test -z "${LD_SHLIB}"; then
#  AC_MSG_ERROR([Can't determine compilation flags.]);
#fi

#
# OS which can handle the Resin launcher
#
resin_pro_plugin=
if test -r "${resin_pro}/modules/c/src/resin/mmap_file.c"; then
   resin_pro_plugin="resin"
fi

resin_pro_plugins="$resin_pro_plugin"

case "$target_cpu" in
  i?86)
  CPU=i386
  ;;

  sparc*)
  if test -n "${b64_jni}"; then
      CPU=sparcv9
  else
      CPU=sparc
  fi
  ;;

  x86_64)
  CPU=$target_cpu
  ;;

  *)
  CPU=$target_cpu
  ;;
esac

case "$target_os" in
  linux*)
  jni_os=linux
  PROXY_LIBS="-lpthread -lrt -lc"
  ;;

  *solaris*)
  jni_os=solaris
  CFLAGS="$CFLAGS -D__SOLARIS__"
  PROXY_LIBS='-lnsl -lsocket -lthread -lc'
  ;;

  *freebsd*)
  PROXY_LIBS='-lpthread'
  jni_os=freebsd

  tmp=`ldd $JAVA_HOME/bin/java | sed 's/.*=>//' | grep -c libc_r`
  tmp=$tmp `ldd $JAVA_HOME/bin/java | sed 's/.*=>//' | grep -c libpthread`
  tmp=$tmp `ldd $JAVA_HOME/bin/java | sed 's/.*=>//' | grep -c libthr`

  case "$tmp" in
  100)
    PROXY_LIBS='-lc_r';
    ;;
  010)
    PROXY_LIBS='-lpthread';
    ;;
  001)
    PROXY_LIBS='-lthr';
    ;;
  *)
    PROXY_LIBS='-lpthread'
    echo "Using -lpthread as default"
    ;;
  esac
  ;;

  *darwin*)
  jni_os=darwin
  LD=gcc
  SO=jnilib
  ;;

  *hpux*)
  if test -r "$JAVA_HOME/include/hpux/jni_md.h"; then
    jni_os=hpux
        else
    jni_os=hp-ux
        fi
  ;;

  *aix*)
        jni_os=aix
  ;;
esac

AC_SUBST(CPU)
AC_SUBST(OS)
AC_SUBST(SO)
AC_SUBST(CFLAGS)
AC_SUBST(jni_cflags)
AC_SUBST(jni_cflags_shlib)
AC_SUBST(jni_ld_shlib)
AC_SUBST(jni_ldflags_shlib)
AC_SUBST(jni_libs_shlib)
AC_SUBST(PROXY_LIBS)
AC_SUBST(SSL_LIBS)

#
# --with-jni-include
#
AC_ARG_WITH(jni-include,
[AS_HELP_STRING([--with-jni-include="-Idir -Idir"],
                [jni include string])],
[
JNI_INCLUDE=${withval}
JNI="yes"
])

#
# --enable-jni
#
AC_ARG_ENABLE(jni,
[AS_HELP_STRING([--enable-jni], [Turn on jni])],
[case "${enableval}" in
 yes) JNI=true ;;
 no)  JNI=false ;;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-jni) ;;
 esac],[JNI=""])

JNI_INCLUDE_DIR=""

if test "$JNI" != "false" ; then
  if test -n "$JNI_INCLUDE"; then
    JNI=yes
    for x in $JNI_INCLUDE; do
      y=${x:2}
      if test -n "$JNI_INCLUDE_DIR"; then
        JNI_INCLUDE_DIR="$JNI_INCLUDE_DIR $y"
      else
        JNI_INCLUDE_DIR="$y"
      fi
    done;
  elif test -r "$JAVA_HOME/include/jni_md.h"; then
    JNI_INCLUDE_DIR="${JAVA_HOME}/include"
    JNI_INCLUDE="-I${JNI_INCLUDE_DIR}"
    JNI=yes
    echo "checking for JNI in $JAVA_HOME/include ... found"
  elif test -r "$JAVA_HOME/include/$jni_os/jni_md.h"; then
    JNI_INCLUDE_DIR="${JAVA_HOME}/include"
    JNI_INCLUDE="-I$JAVA_HOME/include -I$JAVA_HOME/include/$jni_os"
    JNI=yes
    echo "checking for JNI in $JAVA_HOME/include/$jni_os ... found"
  elif test -r "/System/Library/Frameworks/JavaVM.framework/Headers/jni_md.h"; then
    # Darwin
    echo "checking for JNI in /System/Library/Frameworks/JavaVM.framework/Headers ... found"
    JNI_INCLUDE_DIR="/System/Library/Frameworks/JavaVM.framework/Headers"
    JNI_INCLUDE="-I${JNI_INCLUDE_DIR}"
    JNI=yes
  elif test -r "$JAVA_HOME/../Headers/jni_md.h"; then
    # Darwin
    echo "checking for JNI in $JAVA_HOME/../Headers ... found"
    JNI_INCLUDE_DIR="$JAVA_HOME/../Headers"
    JNI_INCLUDE="-I${JNI_INCLUDE_DIR}"
    JNI=yes
  elif test -r "$JAVA_HOME/include/jni.h"; then
    JNI_INCLUDE_DIR="$JAVA_HOME/include"
    JNI_INCLUDE="-I${JNI_INCLUDE_DIR}"
    JNI=yes
    echo "checking for JNI in $JAVA_HOME/include ... found"
  else
    JNI=""
    AC_MSG_ERROR([

    *** Can't find JNI directory in JAVA_HOME=${JAVA_HOME}
    *** JNI is expected in ${JAVA_HOME}/include/$jni_os
  ])
  fi

  HAS_JVMTI=""

  for x in $JNI_INCLUDE_DIR; do
    if test -r "$x/jvmti.h"; then
      HAS_JVMTI="yes"
    fi
  done;

  if test -n "$HAS_JVMTI"; then
    echo "Using JVMTI for class reloading"
    CFLAGS="$CFLAGS -DHAS_JVMTI"
  else
    AC_MSG_ERROR([Can't find JVMTI directory ${JNI_INCLUDE_DIR}/jvmti.h])
  fi
fi

if test "$JNI" = "false" ; then
  resin_pro_plugins=""
  echo "JNI disabled by --disable-jni"
elif test -n "$JNI"; then
  plugins="$plugins resin_os"
else
  plugins=""
  resin_pro_plugins=""
  echo "Can't find JNI include files in JAVA_HOME: $JAVA_HOME"
fi

AC_SUBST(JNI)
AC_SUBST(JNI_INCLUDE)

#
# --enable-ssl
#
AC_ARG_ENABLE(ssl,
[AS_HELP_STRING([--enable-ssl], [Turn on ssl])],
[case "${enableval}" in
 yes) ENABLE_SSL=true ;;
 no)  ENABLE_SSL=false ;;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-ssl) ;;
 esac],[ENABLE_SSL=""])

#
# --with-openssl
#
AC_ARG_WITH(openssl,
[AS_HELP_STRING([--with-openssl=DIR],
                [Openssl directory])],
[
OPENSSL=${withval}
OPENSSL_INCLUDE=${OPENSSL}/include
OPENSSL_LIB=${OPENSSL}/lib
ENABLE_SSL=true
])

#
# --with-openssl-include
#
AC_ARG_WITH(openssl-include,
[AS_HELP_STRING([--with-openssl-include=DIR],
                [Openssl include directory])],
[
OPENSSL_INCLUDE=${withval}
ENABLE_SSL=true

if test ! -r "${OPENSSL_INCLUDE}/openssl/ssl23.h"; then
  AC_MSG_ERROR([Can't find valid OpenSSL include ${OPENSSL_INCLUDE}])
fi
])

#
# --with-openssl-lib
#
AC_ARG_WITH(openssl-lib,
[AS_HELP_STRING([--with-openssl-lib=DIR],
                [Openssl lib directory])],
[
OPENSSL_LIB=${withval}
ENABLE_SSL=true

if test ! -r "${OPENSSL_LIB}/libssl.a" -a \
        ! -r "${OPENSSL_LIB}/libssl.dylib" -a \
  ! -r "${OPENSSL_LIB}/libssl.so"; then
  AC_MSG_ERROR([Can't find valid OpenSSL library ${OPENSSL_LIB}/libssl.*])
fi
])

if test "${ENABLE_SSL}" == false; then
  foo=bar
elif test -n "${OPENSSL_INCLUDE}"; then
  foo=bar
elif test -r ${OPENSSL}/include/openssl/ssl3.h; then
  OPENSSL_INCLUDE=${OPENSSL}/include
elif test -r /usr/include/openssl/ssl3.h; then
  OPENSSL_INCLUDE=/usr/include
elif test -r /usr/local/include/openssl/ssl3.h; then
  OPENSSL_INCLUDE=/usr/local/include
elif test -r /usr/local/ssl/include/openssl/ssl3.h; then
  OPENSSL_INCLUDE=/usr/local/ssl/include
fi

if test "${ENABLE_SSL}" == false; then
  foo=bar
elif test -z "${OPENSSL_LIB}"; then
  SSL_LIBS="${SSL_LIBS} -lssl"
elif test -r "${OPENSSL_LIB}/libssl.so"; then
  SSL_LIBS="${SSL_LIBS} -lssl"
elif test -r "${OPENSSL_LIB}/libssl.dylib"; then
  SSL_LIBS="${SSL_LIBS} -lssl"
elif test -r "${OPENSSL_LIB}/libssl3.so"; then
  SSL_LIBS="${SSL_LIBS} -lssl3"
elif test -r "${OPENSSL_LIB}/libssl3.dylib"; then
  SSL_LIBS="${SSL_LIBS} -lssl3"
elif test -r "${OPENSSL_LIB}/libssl.a"; then
  SSL_LIBS="${SSL_LIBS} ${OPENSSL_LIB}/libssl.a"
elif test -r "${OPENSSL_LIB}/libssl3.a"; then
  SSL_LIBS="${SSL_LIBS} ${OPENSSL_LIB}/libssl3.a"
else
  # probably an error
  SSL_LIBS="${SSL_LIBS} -lssl"
fi

if test "${ENABLE_SSL}" == false; then
  foo=bar
elif test -z "${OPENSSL_LIB}"; then
  SSL_LIBS="${SSL_LIBS} -lcrypto"
elif test -r "${OPENSSL_LIB}/libcrypto.so"; then
  SSL_LIBS="${SSL_LIBS} -lcrypto"
elif test -r "${OPENSSL_LIB}/libcrypto.dylib"; then
  SSL_LIBS="${SSL_LIBS} -lcrypto"
elif test -r "${OPENSSL_LIB}/libcrypto.a"; then
  SSL_LIBS="${SSL_LIBS} ${OPENSSL_LIB}/libcrypto.a"
else
  # probably an error
  SSL_LIBS="${SSL_LIBS} -lcrypto"
fi

SSL_OBJ=ssl_stub.o

if test "${ENABLE_SSL}" == false; then
  echo "Openssl is not enabled"
elif test -z "${OPENSSL_INCLUDE}"; then
  echo "Can't find OpenSSL include '${OPENSSL_INCLUDE}'"
elif test ! -r "${OPENSSL_INCLUDE}/openssl/ssl23.h"; then
  AC_MSG_ERROR([Can't find valid OpenSSL include in ${OPENSSL_INCLUDE}])
else
  echo "Using openssl include in ... ${OPENSSL_INCLUDE}"
  echo "Using openssl lib in ... ${OPENSSL_LIB}"
  echo "Using openssl libraries ... ${SSL_LIBS}"

  cat <<END
END

  if test -x "${apache_dir}/bin/httpd"; then
    apache_ssl=`${apache_dir}/bin/httpd -l 2>&1 | grep ssl`
    if test -n "$apache_ssl"; then
      CFLAGS="$CFLAGS -DOPENSSL"
      echo "Enabling ssl for mod_caucho"
    fi
  elif test -x "${apache_dir}/bin/httpd2"; then
    apache_ssl=`${apache_dir}/bin/httpd2 -l 2>&1 | grep ssl`
    if test -n "$apache_ssl"; then
      CFLAGS="$CFLAGS -DOPENSSL"
      echo "Enabling ssl for mod_caucho"
    fi
  fi

  if test -r "${OPENSSL_INCLUDE}/openssl/engine.h"; then
    CFLAGS_OPENSSL="$OPENSSL_CFLAGS -DSSL_ENGINE"
  fi

  if test -n "${OPENSSL_INCLUDE}"; then
    INCLUDES="$INCLUDES -I${OPENSSL_INCLUDE}"
  fi
  SSL_OBJ=ssl.o
  if test -n "${OPENSSL_LIB}"; then
    LDFLAGS_SHLIB="${LDFLAGS_SHLIB} -L${OPENSSL_LIB}"
  fi
  # PROXY_LIBS="$PROXY_LIBS ${OPENSSL_LIB}/libssl.a ${OPENSSL_LIB}/libcrypto.a"
fi

if test -d /usr/kerberos/include; then
   INCLUDES="$INCLUDES -I/usr/kerberos/include"
fi

#
# test the open ssl
#

if test -n "${SSL_LIBS}"; then
cat >conftest.$ac_ext <<_ACEOF
#include <openssl/ssl.h>
#include <openssl/rsa.h>
#include <openssl/err.h>

int main(int argc, char **argv)
{
  SSLeay_add_ssl_algorithms();
  SSL_load_error_strings();

#if OPENSSL_VERSION_NUMBER >= 0x00907000L
    if (0)
      ERR_print_errors_cb(0, 0);
#endif

  printf("%s\n", OPENSSL_VERSION_TEXT);

  return 0;
}
_ACEOF

if test -n "$OPENSSL_LIB"; then
  FLAG_OPENSSL_LIB="-L${OPENSSL_LIB}"
fi

${CC} -o conftest ${CFLAGS_OPENSSL} ${CFLAGS} ${INCLUDES} conftest.$ac_ext ${FLAG_OPENSSL_LIB} ${SSL_LIBS} ${PROXY_LIBS} 1>/dev/null 2>/dev/null

if test "$?" != 0; then
  ${CC} -o conftest ${CFLAGS_OPENSSL} ${CFLAGS} ${INCLUDES} conftest.$ac_ext -L${OPENSSL_LIB} ${SSL_LIBS} ${PROXY_LIBS}

  AC_MSG_WARN(Can't compile SSL.  Check compilation flags: ${CC} ${CFLAGS_OPENSSL} ${CFLAGS} ${INCLUDES} -L${OPENSSL_LIB} ${SSL_LIBS} ${PROXY_LIBS})
  
  resin_ssl_plugin=""
else
  openssl_version=`./conftest`

  if test "$?" != 0; then
    AC_MSG_WARN(Can't execute SSL.  Check that load version in the library path: ${LD_LIBRARY_PATH} matches the expected version.)
  else
    resin_ssl_plugin="resinssl"
  fi
fi

rm -f conftest conftest.$ac_ext
fi

AC_SUBST(INCLUDES)
AC_SUBST(CFLAGS_OPENSSL)
AC_SUBST(CFLAGS_JNI)
AC_SUBST(SSL_OBJ)

PERL="perl"
#
# --with-perl
#
AC_ARG_WITH(perl,
[AS_HELP_STRING([--with-perl=DIR],
                [Perl binary location])],
[PERL=${withval}])

AC_SUBST(PERL)

SKIP_CHECK_RESIN_SH=false
#
# --with-check-skip
#  
AC_ARG_WITH(check-skip,
[AS_HELP_STRING([--with-check-skip=checks],
                [checks to skip])],
[case "${withval}" in
  *resin_sh*) SKIP_CHECK_RESIN_SH=true ;;
esac])

AC_SUBST(SKIP_CHECK_RESIN_SH)

#
# --ENABLE-debug
#
AC_ARG_ENABLE(debug,
[AS_HELP_STRING([--enable-debug], [Turn on debugging])],
[case "${enableval}" in
 yes) debug=true ;;
 no)  debug=false ;;
 *) AC_MSG_ERROR(bad value ${enableval} for --enable-debug) ;;
 esac],[debug=false])

if test "$debug" = true; then
  CFLAGS="$CFLAGS -DDEBUG -Wall"
  HARDCORE_CFLAGS="$HARDCORE_CFLAGS -DDEBUG"
fi

#
# final cleanup
#

if test -n "$resin_pro_plugins"; then
  resin_pro_plugins="$resin_pro_plugins $resin_ssl_plugin"
fi

plugins="$plugins"

if test -z "${is_dev}"; then
  plugins="$plugins $resin_pro_plugins"
  resin_pro_plugins="$plugins"
fi

AC_OUTPUT([
Makefile
modules/c/src/Makefile
modules/c/src/common/Makefile
modules/c/src/apache2/Makefile
modules/c/src/resin_os/Makefile
init.d/resin
bin/resinctl
], [])

if test -r "modules/c/src/resin/mmap_file.c"; then
  AC_OUTPUT([
    modules/c/src/resin/Makefile
    modules/c/src/resinssl/Makefile
  ])
elif test -r "../pro/modules/c/src/resin/mmap_file.c"; then
  AC_OUTPUT([
    ../pro/modules/c/src/Makefile
    ../pro/modules/c/src/resin/Makefile
    ../pro/modules/c/src/resinssl/Makefile
  ])
fi

#if test -n "${resin_pro_plugins}"; then
#  AC_OUTPUT([
#    modules/c/src/resin/Makefile
#  ])
#fi

echo ""
echo ""
echo "Resin Configuration Summary:"
echo ""
echo "  RESIN       : $PACKAGE_VERSION"
echo "    home      : ${resin_home}"
echo "    root      : ${resin_root}"
echo "    conf      : ${resin_conf}"
echo "    log       : ${resin_log}"
echo "    plugins   : ${plugins}"

if test -n "${resin_init_d}"; then
  echo "    init      : ${resin_init_d}"
fi

echo ""

echo "  JAVA_HOME   : ${JAVA_HOME}"
echo ""

if test "$JNI" = "false" ; then
  echo "  JNI         : Disabled by --disable-jni"
elif test -z "$JNI"; then
  echo "  JNI         : No JNI has been found in JAVA_HOME"
  echo "    *** JNI libraries cannot be compiled ***"
else
  if test -n "${b64_jni}"; then
    echo "  JNI         : 64-bit"
  else
    echo "  JNI         : 32-bit"
  fi

  echo "    include       : ${JNI_INCLUDE}"
  echo "    CFLAGS        : ${JNI_CFLAGS}"
  echo "    cflags_shlib  : ${jni_cflags_shlib}"
  echo "    ld_shlib      : ${jni_ld_shlib}"
  echo "    ldflags_shlib : ${jni_ldflags_shlib}"
  echo "    libs_shlib    : ${jni_libs_shlib}"

  if test -n "$epoll"; then
    echo "    epoll() for keepalives"
  elif test -n "$poll"; then
    echo "    poll() for keepalives"
  else
    echo "    select() for keepalives"
  fi

  echo ""

  if test "${ENABLE_SSL}" = "false"; then
    echo "  OPENSSL     : Disable by --disable-ssl"
    echo ""
  elif test -z "${OPENSSL_INCLUDE}"; then
    echo "  OPENSSL     : No OpenSSL has been found"
    echo "    *** OpenSSL libraries cannot be compiled ***"
    echo ""
  elif test -n "${resin_pro_plugin}"; then
    echo "  OPENSSL     : ${openssl_version}"
    echo "    include   : ${OPENSSL_INCLUDE}"
    echo "    lib       : ${OPENSSL_LIB}"
    echo "    libraries : ${SSL_LIBS}"
    echo ""
  fi
fi

if test -n "${apache}"; then
  echo "  APACHE          : ${apache_dir}"
  echo "    conf          : ${apache_conf}"
  echo "    libexec       : ${apache_libexec}"
  echo "    include       : ${apache_include}"
  echo "    CFLAGS        : ${apache_cflags}"
  echo "    cflags_shlib  : ${apache_cflags_shlib}"
  echo "    ld_shlib      : ${apache_ld_shlib}"
  echo "    ldflags_shlib : ${apache_ldflags_shlib}"
  echo "    libs_shlib    : ${apache_libs_shlib}"
  echo "    apache_shm    : ${apache_shm}"
  echo "    apache_24     : ${apache_24}"

  echo ""
fi

if test -n "${is_dev}"; then
  echo "  DEVELOPMENT BUILD"
  echo ""
fi

echo ""
