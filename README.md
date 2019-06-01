# obs-vintage-filter
An OBS Studio filter where the source can be set to be black &amp; white or sepia.

## Installing
On Windows, unzip the obs-vintage-filter folder and copy the obs-plugins and data folders to the obs-studio install directory.

On Linux, for Debian based distros, there is a .deb file available to install the filter.

Mac isn't supported at this time.

## Compiling on Linux
```
git clone https://github.com/cg2121/obs-vintage-filter.git
cd obs-vintage-filter
mkdir build && cd build
cmake -DLIBOBS_INCLUDE_DIR="...path to libobs source directory..." -DLIBOBS_LIB="...path to libobs.so file..." -DCMAKE_INSTALL_PREFIX=/usr ..
make -j4
sudo make install
```
