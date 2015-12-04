#!/bin/bash

set -e

TMPDIR=$(mktemp -d)

convert -density 96x96 "$1" "$TMPDIR/frame-%d.png"
ffmpeg -y -i "$TMPDIR/frame-%d.png" -r 30 -b 2500k \
    -vframes "$(ls "$TMPDIR" | wc -l)" "$2"
