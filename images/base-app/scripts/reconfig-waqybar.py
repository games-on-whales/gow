#!/usr/bin/env python3
import os

WAYBAR_HIDDEN = os.getenv("WAYBAR_HIDDEN")
set_hidden = True if WAYBAR_HIDDEN == "true" or WAYBAR_HIDDEN == "yes" else False

data_out: str = ""
nest_count = 0

with open(f"{os.environ['HOME']}/.config/waybar/config.jsonc", "r") as config_file:
    for line in config_file:
        if line.find("{") != -1 or line.find("[") != -1: nest_count += 1
        if line.find("}") != -1 or line.find("]") != -1: nest_count -= 1
        if nest_count == 1:
            if line.find("layer") != -1:
                if set_hidden:
                    data_out += line.replace("top", "bottom")
                else:
                    data_out += line.replace("bottom", "top")
                continue
            if line.find("mode") != -1:
                if set_hidden:
                    data_out += line.replace("dock", "hide")
                else:
                    data_out += line.replace("hide", "dock")
                continue
            if line.find("start_hidden") != -1:
                if set_hidden:
                    data_out += line.replace("false", "true")
                else:
                    data_out += line.replace("true", "false")
                continue
        data_out += line

with open(f"{os.environ['HOME']}/.config/waybar/config.jsonc", "w") as config_file:
    config_file.write(data_out)