#!/bin/sh

mkdir -p ${MESON_INSTALL_PREFIX}/Contents/Frameworks
cp -R /Library/Frameworks/SDL2.framework ${MESON_INSTALL_PREFIX}/Contents/Frameworks

# Alterning library search paths for the app:
list_lib='gtk4 libxml-2.0 pangoft2 epoxy libavutil libavcodec libavformat libswscale'
for lib in $liste_lib
do
  install_name_tool -change @rpath/$lib.framework/Versions/A/$lib \
      @executable_path/../FrameWorks/$lib.framework/Versions/A/$lib \
      ${MESON_INSTALL_PREFIX}/Contents/MacOS/myapp
done
