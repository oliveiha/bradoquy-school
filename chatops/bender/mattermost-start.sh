#!/bin/sh
# Mais info em https://docs.mattermost.com/administration/config-settings.html#allow-untrusted-internal-connections-to
docker run --name mattermost-preview \
    -e MM_SERVICESETTINGS_ALLOWEDUNTRUSTEDINTERNALCONNECTIONS='localhost 0.0.0.0/0 10.0.0.0/8 172.17.0.0/16 192.168.0.0/16' \
    -d --publish 8065:8065 \
    mattermost/mattermost-preview
