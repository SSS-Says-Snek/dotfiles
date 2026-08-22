#!/bin/sh
if [ -f /usr/share/glvnd/egl_vendor.d/10_nvidia.json ]; then
    export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json
fi

export QSG_ATLAS_WIDTH=512
export QSG_ATLAS_HEIGHT=512
export QML_XHR_ALLOW_FILE_READ=1

exec quickshell -p "$(dirname "$(readlink -f "$0")")/shell.qml" "$@"
