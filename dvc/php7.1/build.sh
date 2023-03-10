TERMUX_PKG_HOMEPAGE=https://php.net
TERMUX_PKG_DESCRIPTION="Server-side, HTML-embedded scripting language"
TERMUX_PKG_LICENSE="PHP-3.0"
TERMUX_PKG_MAINTAINER="@Dichvucoder"
TERMUX_PKG_VERSION=7.1.12
TERMUX_PKG_SHA256=a0118850774571b1f2d4e30b4fe7a4b958ca66f07d07d65ebdc789c54ba6eeb3
TERMUX_PKG_SRCURL=https://www.php.net/distributions/php-${TERMUX_PKG_VERSION}.tar.xz
# Build native php for phar to build (see pear-Makefile.frag.patch):
TERMUX_PKG_HOSTBUILD=true
# Build the native php without xml support as we only need phar:
TERMUX_PKG_EXTRA_HOSTBUILD_CONFIGURE_ARGS="--disable-libxml --disable-dom --disable-simplexml --disable-xml --disable-xmlreader --disable-xmlwriter --without-pear"
TERMUX_PKG_DEPENDS="libandroid-glob, libxml2, liblzma, openssl-1.1, pcre, zlib, pcre2, libbz2, libcrypt, libcurl, libgd, readline, freetype, perl"
TERMUX_PKG_CONFLICTS="php, php-mysql, php-dev"
TERMUX_PKG_RM_AFTER_INSTALL="php/php/fpm"
TERMUX_PKG_SERVICE_SCRIPT=("php-fpm" 'mkdir -p ~/.php\nif [ -f "$HOME/.php/php-fpm.conf" ]; then CONFIG="$HOME/.php/php-fpm.conf"; else CONFIG="$PREFIX/etc/php-fpm.conf"; fi\nexec php-fpm -F -y $CONFIG -c ~/.php/php.ini 2>&1')

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_func_res_nsearch=no
--enable-bcmath
--enable-calendar
--enable-exif
--enable-gd-native-ttf=$TERMUX_PREFIX
--enable-mbstring
--enable-opcache
--enable-pcntl
--enable-sockets
--enable-zip
--mandir=$TERMUX_PREFIX/share/man
--with-bz2=$TERMUX_PREFIX
--with-curl=$TERMUX_PREFIX
--with-freetype-dir=$TERMUX_PREFIX
--with-gd=$TERMUX_PREFIX
--with-iconv=$TERMUX_PREFIX
--with-libxml-dir=$TERMUX_PREFIX
--with-openssl=$TERMUX_PREFIX
--with-pcre-regex=$TERMUX_PREFIX
--with-png-dir=$TERMUX_PREFIX
--with-readline=$TERMUX_PREFIX
--with-zlib
--with-pgsql=shared,$TERMUX_PREFIX
--with-pdo-pgsql=shared,$TERMUX_PREFIX
--with-mysqli=shared,$TERMUX_PREFIX/bin/mysql_config
--with-pdo-mysql=shared,$TERMUX_PREFIX/bin/mysql
--with-mysql-sock=$TERMUX_PREFIX/tmp/mysqld.sock
--with-apxs2=$TERMUX_PREFIX/bin/apxs
--enable-fpm
--sbindir=$TERMUX_PREFIX/bin
"

termux_step_pre_configure () {
	#because the new mariadb hides away all these includes inside server subdir
	CFLAGS+=" -I$TERMUX_PREFIX/include/mysql/server -I$TERMUX_PREFIX/include/mysql"
	LDFLAGS+=" -landroid-glob -llog"

	export PATH=$PATH:$TERMUX_PKG_HOSTBUILD_DIR/sapi/cli/
	export NATIVE_PHP_EXECUTABLE=$TERMUX_PKG_HOSTBUILD_DIR/sapi/cli/php

	# Run autoconf since we have patched config.m4 files.
	autoconf

	export EXTENSION_DIR=$TERMUX_PREFIX/lib/php
}

termux_step_post_configure () {
	# Avoid src/ext/gd/gd.c trying to include <X11/xpm.h>:
	sed -i 's/#define HAVE_GD_XPM 1//' $TERMUX_PKG_BUILDDIR/main/php_config.h
	# Avoid src/ext/standard/dns.c trying to use struct __res_state:
	sed -i 's/#define HAVE_RES_NSEARCH 1//' $TERMUX_PKG_BUILDDIR/main/php_config.h
}

termux_step_post_make_install () {
	mkdir -p $TERMUX_PREFIX/etc/php-fpm.d
	cp sapi/fpm/php-fpm.conf $TERMUX_PREFIX/etc/
	cp sapi/fpm/www.conf $TERMUX_PREFIX/etc/php-fpm.d/

	sed -i 's/SED=.*/SED=sed/' $TERMUX_PREFIX/bin/phpize
}
