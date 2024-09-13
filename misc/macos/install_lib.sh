#!/bin/sh

lib_dir=${MESON_INSTALL_PREFIX}/Contents/Resources/lib

function inst_tool
{
  lib_path=$1
  libf=`echo $1|sed 's/\//\n/g'|grep '*.dylib'`
  install_name_tool -change "@rapth/$1" "@executable_path/../$libf" ${MESON_INSTALL_PREFIX}/Contents/MacOS/atomes-bin
}

function lib_copy_dependency
{
  local lib_path=$1
  local lib=`echo $1|sed 's/\// /g'|awk '{printf $NF}'`
  echo "Library: "$lib", in : "$lib_path
  if [ ! -f $lib_dir/$lib ]; then
    cp -R -L $lib_path $lib_dir
    local liste_dolib=`otool -L $lib_dir/$lib|grep 'dylib'|grep 'opt'|awk '{printf $1" "}'`    
    local liste_dopath=`otool -L $lib_path|grep 'rpath'|grep 'dylib'|sed 's/@rpath//g'|awk '{printf $1" "}'`
    local rpath=`otool -L $lib_path|head -n 1|sed 's/'$lib'//1'|sed 's/\/://g'`
    #if [ $lib == "libjxl.0.10.dylib" ]; then
    #  echo "liste_dolib  = "$liste_dolib
    #  echo "liste_dopath = "$liste_dopath
    #  echo "rpath        = "$rpath 
    #fi
    for dolib in $liste_dolib
    do 
      lib_copy_dependency $dolib
    done
    # liste_dolib=`otool -L $lib_dir/$lib|grep '/usr'|awk '{printf $1" "}'`
    # for dolib in $liste_dolib
    # do 
    #   lib_copy_dependency $dolib
    # done
    for dopath in $liste_dopath
    do
      lib_copy_dependency $rpath$dopath
    done
  fi
}

liste_lib=`otool -L atomes-bin|grep 'dylib'|grep 'opt'|awk '{printf $1" "}'`
mkdir -p $lib_dir
for llib in $liste_lib
do
  lib_copy_dependency $llib
  inst_tool $llib  
done

liste_lib=`otool -L atomes-bin|grep 'dylib'|grep 'rpath'|awk '{printf $1" "}'`
for llib in $liste_lib
do
  lib_copy_dependency $llib
  inst_tool $llib  
done

#Extra stuff because you'll never know
cp -R -L /opt/homebrew/lib/gtk-4.0 $lib_dir
cp -R -L /opt/homebrew/lib/gdk-pixbuf-2.0 $lib_dir
