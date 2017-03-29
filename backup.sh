#!/bin/bash

set -e

: ${MONGO_HOST:?}
: ${MONGO_DB:?}
: ${MONGO_USERNAME:?}
: ${MONGO_PASSWORD:?}
: ${S3_BUCKET:?}
: ${AWS_ACCESS_KEY_ID:?}
: ${AWS_SECRET_ACCESS_KEY:?}
: ${DATE_FORMAT:?}
: ${FILE_PREFIX:?}

FOLDER=/backup
DUMP_OUT=dump

FILE_NAME=${FILE_PREFIX}$(date -u +${DATE_FORMAT}).tar.gz

echo "Creating backup folder..."

rm -fr ${FOLDER} && mkdir -p ${FOLDER} && cd ${FOLDER}

echo "Starting backup..."

mongodump --host=${MONGO_HOST} --db=${MONGO_DB} --db=${MONGO_USERNAME} --db=${MONGO_PASSWORD} --out=${DUMP_OUT}

echo "Compressing backup..."

tar -zcvf ${FILE_NAME} ${DUMP_OUT} && rm -fr ${DUMP_OUT}

echo "Uploading to S3..."

aws s3api put-object --bucket ${S3_BUCKET} --key ${FILE_NAME} --body ${FILE_NAME}

echo "Removing backup file..."

rm -f ${FILE_NAME}

echo "Done!"
