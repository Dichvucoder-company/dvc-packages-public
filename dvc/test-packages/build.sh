TERMUX_PKG_HOMEPAGE=https://github.com/Dichvucoder/dvc-packages
TERMUX_PKG_DESCRIPTION="Dummy test for dvc packages"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@Dichvucoder"
TERMUX_PKG_VERSION=0.1.1
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true


termux_step_make() {
	$CC $CFLAGS $CPPFLAGS $TERMUX_PKG_BUILDER_DIR/main.c -o hello-dvc
}

termux_step_make_install() {
	install -Dm700 hello-dvc $TERMUX_PREFIX/bin/hello-dvc
}
