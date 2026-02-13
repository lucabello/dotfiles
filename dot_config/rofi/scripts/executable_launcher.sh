#!/usr/bin/env bash

source ~/.config/rofi/scripts/theme
THEME="$THEME_FOLDER"/launcher.rasi

rofi -show drun -theme "$THEME"
