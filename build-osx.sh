#!/bin/sh

if [ -d /tmp/atomes.app ]; then
  rm -rf /tmp/atomes.app
fi

# meson setup buildir -Dopenmp=false --prefix=/tmp/atomes.app --bindir=Contents/MacOS -Dbuildtype=release --wipe
# meson setup buildir --prefix=/tmp/atomes.app --bindir=Contents/MacOS -Dbuildtype=debug --wipe
meson setup buildir --prefix=/tmp/atomes.app --bindir=Contents/MacOS -Dbuildtype=release --wipe
meson compile -C buildir
meson install -C buildir
