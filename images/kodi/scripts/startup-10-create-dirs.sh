#!/bin/bash -e

gow_log "[start-create-dirs] Begin"

# configure the controller.
if [ ! -d "${HOME}/.kodi/userdata/addon_data/peripheral.joystick/resources/buttonmaps/xml/linux" ]
then
    gow_log "[start-create-dirs] Creating controller config file."
    mkdir -p "${HOME}/.kodi/userdata/addon_data/peripheral.joystick/resources/buttonmaps/xml/linux/"
    cp "/opt/gow/Xbox_controller.xml" "${HOME}/.kodi/userdata/addon_data/peripheral.joystick/resources/buttonmaps/xml/linux/Wolf_X-Box_One__virtual__pad_11b_8a.xml"
    cp "/opt/gow/Switch_controller.xml" "${HOME}/.kodi/userdata/addon_data/peripheral.joystick/resources/buttonmaps/xml/linux/Wolf_Nintendo__virtual__pad_14b_6a.xml"
    cp "/opt/gow/PS_controller.xml" "${HOME}/.kodi/userdata/addon_data/peripheral.joystick/resources/buttonmaps/xml/linux/Wolf_DualSense__virtual__pad_13b_8a.xml"
    cp "/opt/gow/settings.xml" "${HOME}/.kodi/userdata/addon_data/peripheral.joystick/settings.xml"
fi

gow_log "[start-create-dirs] End"
