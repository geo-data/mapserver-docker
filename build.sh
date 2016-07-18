#!/usr/bin/env bash

##
# Build the docker image
#

# The MapServer git tag to checkout.
git_tag=master

# Exit on any non-zero status.
trap 'exit' ERR
set -E

# The APT dependencies for building MapServer.
build_dependencies="git
  build-essential
  cmake"

# Install the build dependencies.
apt-get update -y
apt-get install -y $build_dependencies

# Install the runtime dependencies.
apt-get install -y \
    libfcgi-dev \
    fcgiwrap \
    nginx \
    libcairo2-dev \
    libpixman-1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libexempi-dev \
    apache2-dev \
    libapr1-dev \
    libaprutil1-dev \
    libxslt1-dev \
    ruby-dev \
    librsvg2-dev

# Create the mapserver build environment.
cd /tmp
git clone https://github.com/mapserver/mapserver.git
cd mapserver
git checkout "${git_tag}"
mkdir build
cd build

# Configure Mapserver. Inital list generated with:
# grep -o -P "WITH_[\w]+" ../CMakeLists.txt | sort | uniq
cmake -DCMAKE_PREFIX_PATH=/usr/local \
    -DWITH_APACHE_MODULE=OFF \
    -DWITH_CAIRO=ON \
    -DWITH_CAIROSVG=ON \
    -DWITH_CLIENT_WFS=ON \
    -DWITH_CLIENT_WMS=ON \
    -DWITH_CSHARP=OFF \
    -DWITH_CURL=ON \
    -DWITH_EXEMPI=ON \
    -DWITH_FCGI=ON \
    -DWITH_FRIBIDI=ON \
    -DWITH_GDAL=ON \
    -DWITH_GENERIC_NINT=ON \
    -DWITH_GEOS=ON \
    -DWITH_GIF=ON \
    -DWITH_HARFBUZZ=ON \
    -DWITH_ICONV=ON \
    -DWITH_JAVA=OFF \
    -DWITH_KML=ON \
    -DWITH_LIBXML2=ON \
    -DWITH_MSSQL2008=OFF \
    -DWITH_MYSQL=ON \
    -DWITH_OGR=ON \
    -DWITH_ORACLESPATIAL=OFF \
    -DWITH_ORACLE_PLUGIN=OFF \
    -DWITH_PERL=ON \
    -DWITH_PHP=OFF\
    -DWITH_PIXMAN=ON \
    -DWITH_POINT_Z_M=ON \
    -DWITH_POSTGIS=ON \
    -DWITH_PROJ=ON \
    -DWITH_PYTHON=ON \
    -DWITH_RSVG=ON\
    -DWITH_RUBY=ON \
    -DWITH_SOS=ON \
    -DWITH_SVGCAIRO=OFF\
    -DWITH_THREAD_SAFETY=ON \
    -DWITH_V8=OFF \
    -DWITH_WCS=ON \
    -DWITH_WFS=ON \
    -DWITH_WMS=ON \
    -DWITH_XMLMAPFILE=ON \
    ../

# Build and install Mapserver.
cpu_count=$( grep processor /proc/cpuinfo | wc -l )
make -j${cpu_count}
make -j${cpu_count} install

# Install the test mapfile.
cd /tmp/build
mkdir -p /usr/local/share/mapserver/examples
cp test.map /usr/local/share/mapserver/examples/

# Set up the Nginx Mapserver configuration.
cp ./mapserver /etc/nginx/sites-available/mapserver
ln -s /etc/nginx/sites-available/mapserver /etc/nginx/sites-enabled/mapserver
rm /etc/nginx/sites-enabled/default

# Set up the run script for starting services.
cp ./run.sh /usr/local/bin/run.sh
chmod +x /usr/local/bin/run.sh

# Remove the build dependencies.
apt-get remove -y $build_dependencies

# Clean up APT when done.
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
