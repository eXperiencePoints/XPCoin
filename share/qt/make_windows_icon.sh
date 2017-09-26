#!/bin/bash
# create multiresolution windows icon
ICON_DST=../../src/qt/res/icons/XP.ico

convert ../../src/qt/res/icons/XP-16.png ../../src/qt/res/icons/XP-32.png ../../src/qt/res/icons/XP-48.png ${ICON_DST}
