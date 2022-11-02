#!/bin/sh

# Global variables
DIR_CONFIG="/etc/franklink"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write franklink configuration
cat << EOF > ${DIR_TMP}/heroku.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "${ID}",
                "alterId": ${AID}
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "${WSPATH}"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get franklink executable release
# https://github.com/franklin76/franklink/raw/master/franklink.zip
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/franklin76/franklink/raw/master/franklink.zip -o ${DIR_TMP}/franklink.zip
busybox unzip ${DIR_TMP}/franklink.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/frankctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install franklink
install -m 755 ${DIR_TMP}/franklink ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run franklink
${DIR_RUNTIME}/franklink -config=${DIR_CONFIG}/config.pb
