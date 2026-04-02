#!/bin/bash

# Download themes
PEGASUS_THEMES_DIR=$HOME/.config/pegasus-frontend/themes
mkdir -p "${PEGASUS_THEMES_DIR}"


declare -A PEGASUS_THEMES=( \
["bartopOS"]="https://github.com/fastpop72/bartopOS/archive/master.zip" \
["clearOS"]="https://github.com/PlayingKarrde/clearOS/archive/master.zip" \
["EasyLaunch"]="https://github.com/VGmove/EasyLaunch/archive/master.zip" \
["epic-memories-theme"]="https://github.com/FrenchGithubUser/epic-memories-theme/archive/master.zip" \
["FlixNet_Plus"]="https://github.com/ZagonAb/FlixNet_Plus/archive/master.zip" \
["gameOS"]="https://github.com/jimbob4000/gameOS/archive/master.zip" \
["gameOS-fire-sKye"]="https://github.com/HomeStarRunnerTron/gameOS-fire-sKye/archive/master.zip" \
["library"]="https://github.com/Fr75s/library/archive/master.zip" \
["Minimis"]="https://github.com/waldnercharles/Minimis/archive/master.zip" \
["neoretro"]="https://github.com/valsou/neoretro/archive/master.zip" \
["pegasus-theme-9999999-in-1"]="https://github.com/mmatyas/pegasus-theme-9999999-in-1/archive/master.zip" \
["pegasus-theme-es2-simple"]="https://github.com/mmatyas/pegasus-theme-es2-simple/archive/master.zip" \
["pegasus-theme-flixnet"]="https://github.com/mmatyas/pegasus-theme-flixnet/archive/master.zip" \
["pegasus-theme-grid-micro"]="https://github.com/mmatyas/pegasus-theme-grid-micro/archive/master.zip" \
["pegasus-theme-gpiOS"]="https://github.com/SinisterSpatula/pegasus-theme-gpiOS/archive/master.zip" \
["pegasus-theme-homage"]="https://github.com/asdfgasfhsn/pegasus-theme-homage/archive/master.zip" \
["pegasus-theme-refiOS"]="https://github.com/eleo95/pegasus-theme-refiOS/archive/master.zip" \
["prosperoOS"]="https://github.com/PlayingKarrde/prosperoOS/archive/master.zip" \
["retromega"]="https://github.com/djfumberger/retromega/archive/master.zip" \
["retromega-next"]="https://github.com/plaidman/retromega-next/archive/master.zip" \
["RP-RG351"]="https://github.com/dragoonDorise/RP-RG351/archive/master.zip" \
["shinretro"]="https://github.com/TigraTT-Driver/shinretro/archive/master.zip" \
)

# ["pegasus-theme-npe"]="https://github.com/riquenunes/pegasus-theme-npe/archive/master.zip" \
# ["revolutionmenu"]="https://github.com/travrei/revolutionmenu/archive/master.zip" \

# Loop through and download all the themes above
for CURR_THEME in "${!PEGASUS_THEMES[@]}"
do
  THEME_NAME=$CURR_THEME
  THEME_URL=${PEGASUS_THEMES[$CURR_THEME]}
  if [[ ! -d ${PEGASUS_THEMES_DIR}/${THEME_NAME}-master ]] ; then
    echo "Downloading Pegasus Theme: ${THEME_NAME} from ${THEME_URL}"
    wget -q --show-progress ${THEME_URL} --output-document=/tmp/theme.zip
    echo "Extracting"
    7z x /tmp/theme.zip -bso0 -bse0 -bsp1 -o"$PEGASUS_THEMES_DIR"
    echo "Cleanup"
    rm /tmp/theme.zip
  fi
done
