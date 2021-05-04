#!/usr/bin/env sh

curl -X 'PUT' 'http://localhost:8080/mockserver/openapi' -H 'accept: application/json' \
  -d "{ 'specUrlOrPayload' : '${MOCKDATA_PATH}/openapi.yaml' }" > /dev/null
