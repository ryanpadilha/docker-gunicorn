#!/usr/bin/env bash

set -eo pipefail

echo "Building nginx ${NGINX_VERSION}"

mkdir -p ${BUILD_ROOT}/nginx

echo "Getting nginx tarball"
wget -O ${BUILD_ROOT}/nginx.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

echo "Building nginx"
tar -xC ${BUILD_ROOT}/nginx --strip-components=1 -f ${BUILD_ROOT}/nginx.tar.gz
cd ${BUILD_ROOT}/nginx

CONFIG_ARGS="--prefix=${INSTALL_ROOT} \
	--conf-path=/etc/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--pid-path=/var/log/nginx/nginx.pid \
	--http-log-path=/var/log/nginx/access.log \
	--user=${WWW_USER} --group=${WWW_GROUP} \
	--with-http_auth_request_module \
	--with-http_ssl_module \
	--with-http_v2_module \
	--without-http_ssi_module \
	--without-http_uwsgi_module \
	--without-http_scgi_module \
	--with-pcre \
	"

./configure ${CONFIG_ARGS}
make -j 2
make install
# In case the mime-support package gets installed at some point, we don't want
# its mime.types overwriting NGINX's.  They are in different formats.
mkdir -p /etc/nginx
mv /etc/mime.types /etc/nginx/mime.types
ldconfig
