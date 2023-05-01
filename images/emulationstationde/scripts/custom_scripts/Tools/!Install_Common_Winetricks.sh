#!/bin/bash
set -e
source /opt/gow/bash-lib/utils.sh

#export WINEARCH=win64
#export WINEPREFIX=~/.wine
#export MESA_EXTENSION_MAX_YEAR=2008
#export __GL_ExtensionStringVersion=17700
winetricks d3dcompiler_43 d3dcompiler_47 d3dx9 d3dx10 d3dx10_43 d3dx11_43 d3dx9_43 dotnet40 dotnet48 gdiplus msaa msflxgrd msftedit mshflxgd msls31 msxml6 riched20 riched30 richtx32 ucrtbase2019 vcrun2005 vcrun2013 vcrun2019 vcrun6 vcrun6sp6 wmp11 xmllite xna40 xvid tahoma corefonts --force