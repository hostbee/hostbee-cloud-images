#!/bin/bash

echo "CN_FLAG: ${CN_FLAG}"
echo "MINIO_ENDPOINT: ${MINIO_ENDPOINT}"

TODAY=$(TZ=Asia/Shanghai date +%Y-%m-%d)
if [ "${CN_FLAG}" = "true" ]; then
  BUCKET=hostbee-cloud-images-cn
else
  BUCKET=hostbee-cloud-images
fi

CURRENT_STAMP=$(curl -s "$MINIO_ENDPOINT/$BUCKET/LATEST_BUILD.txt")
echo "Stamp from remote bucket ${BUCKET}: ${CURRENT_STAMP}"

STAMP=""

# check if the current stamp string is staring with "/weekly/", then get the part afer it
if [[ "${CURRENT_STAMP}" =~ ^/weekly/ ]]; then
  CURRENT_STAMP=$(echo "${CURRENT_STAMP}" | sed 's|^/weekly/||')
  DATE=$(echo "${CURRENT_STAMP}" | cut -d'_' -f1)
  STAMP=$(echo "${CURRENT_STAMP}" | cut -d'_' -f2)

  if [ "${DATE}" != "${TODAY}" ]; then
    echo "Stamp from remote bucket ${BUCKET} is a weekly stamp, but the date is not today, setting the stamp to today"
    STAMP="${TODAY}_1"
  else
    echo "Stamp from remote bucket ${BUCKET} is a weekly stamp, bumping the stamp number"
    STAMP="${DATE}_$(($STAMP + 1))"
  fi
else
  echo "Stamp from remote bucket ${BUCKET} is not a weekly stamp"
  STAMP="${TODAY}_1"
fi

echo "Stamp: ${STAMP}"
echo "STAMP=${STAMP}" >> $GITHUB_OUTPUT
