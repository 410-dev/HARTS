#!/bin/bash
export CHEVENT="$("$SYSTEM/Orta/fswatch" --one-event -L -r "$SYSTEM")"
mkdir -p "~/Library/Orta"
echo "$CHEVENT" >> "~/Library/Orta/FileChanged.orta"