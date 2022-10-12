#!/bin/sh

java -Dfile.encoding=UTF-8 -cp /mockserver.jar org.mockserver.cli.Main -serverPort "${API_PORT}"
