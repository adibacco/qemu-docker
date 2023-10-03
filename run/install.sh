#!/usr/bin/env bash
set -Eeuo pipefail

TMP="/boot.img"

rm -f "$TMP"

if [[ ${BOOT} == 'http'* ]]; then

  info "Downloading ${BOOT} as boot image..."

  # Check if running with interactive TTY or redirected to docker log
  if [ -t 1 ]; then
    PROGRESS="--progress=bar:noscroll"
  else
    PROGRESS="--progress=dot:giga"
  fi

  [[ "${DEBUG}" == [Yy1]* ]] && set -x

  { wget "$BOOT" -O "$TMP" -q --no-check-certificate --show-progress "$PROGRESS"; rc=$?; } || :

  (( rc != 0 )) && error "Failed to download ${BOOT}, reason: $rc" && exit 60
  [ ! -f "$TMP" ] && error "Failed to download ${BOOT}" && exit 61

  SIZE=$(stat -c%s "$TMP")

  if ((SIZE<100000)); then
    error "Invalid ISO file: Size is smaller than 100 KB" && exit 62
  fi
else
  info "Copying file ${BOOT} as boot image..."

  ln -s $BOOT $TMP
#  { sshpass -p 'user' scp -o StrictHostKeyChecking=no "$BOOT" "$TMP" ; rc=$?; } || :

#  (( rc != 0 )) && error "Failed to transfer ${BOOT}, reason: $rc" && exit 60
#  [ ! -f "$TMP" ] && error "Failed to transfer ${BOOT}" && exit 61

fi

FILE="$STORAGE/boot.img"

mv -f "$TMP" "$FILE"

{ set +x; } 2>/dev/null
[[ "${DEBUG}" == [Yy1]* ]] && echo

return 0
