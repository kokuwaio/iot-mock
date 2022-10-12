#!/usr/bin/env sh

curl -X 'PUT' 'http://localhost:${API_PORT}/mockserver/openapi' -H 'accept: application/json' \
  -d "{ 'specUrlOrPayload' : '${MOCKDATA_PATH}/openapi.yaml' }" > /dev/null
