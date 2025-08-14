#!/bin/bash

echo "CN_FLAG: ${CN_FLAG}"

TODAY=$(TZ=Asia/Shanghai date +%Y-%m-%d)
if [ "${CN_FLAG}" = "true" ]; then
  BUCKET=hostbee-cloud-images-cn
else
  BUCKET=hostbee-cloud-images
fi

CURRENT_STAMP=$(curl -s "https://s3.4299.net/$BUCKET/LATEST_BUILD.txt")

STAMP=""

if [[ "${CURRENT_STAMP}" =~ ^/weekly/ ]]; then
  CURRENT_STAMP=$(echo "${CURRENT_STAMP}" | sed 's|^/weekly/||')
  DATE=$(echo "${CURRENT_STAMP}" | cut -d'_' -f1)
  STAMP=$(echo "${CURRENT_STAMP}" | cut -d'_' -f2)

  if [ "${DATE}" != "${TODAY}" ]; then
    STAMP="${TODAY}_1"
  else
    STAMP="${DATE}_$(($STAMP + 1))"
  fi
else
  STAMP="${TODAY}_1"
fi

echo "Stamp: ${STAMP}"
echo "STAMP=${STAMP}" >> $GITHUB_OUTPUT
