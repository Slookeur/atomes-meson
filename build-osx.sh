#!/bin/sh

meson setup buildir --prefix=/tmp/atomes.app --bindir=Contents/MacOS -Dbuildtype=release --wipe
meson compile -C buildir
meson install -C buildir
