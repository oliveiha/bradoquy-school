#!/bin/bash

export MATTERMOST_ENDPOINT=/bender/incoming
export MATTERMOST_TOKEN=d5s86gcgxfdzujwkq1jdud69fo
export MATTERMOST_INCOME_URL=http://localhost:8065/hooks/c9nkk7s9wibctdrd1kxgze8z6y
export HUBOT_LOG_LEVEL="debug"

./bin/hubot -a mattermost
