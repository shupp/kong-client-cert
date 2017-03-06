#!/bin/bash

TEMPLATE_DIR=/usr/local/share/lua/5.1/kong/templates
NGINX_TEMPLATE=${TEMPLATE_DIR}/nginx.lua
NGINX_KONG_TEMPLATE=${TEMPLATE_DIR}/nginx_kong.lua
NGINX_LEN=`wc -l ${NGINX_TEMPLATE} | awk '{ print $1 }'`
NGINX_KONG_LEN=`wc -l ${NGINX_KONG_TEMPLATE} | awk '{ print $1 }'`

# strip return template wrapper lines
NGINX_CONTENTS=`cat ${NGINX_TEMPLATE} | sed -e 1d -e ${NGINX_LEN}d`
NGINX_KONG_CONTENTS=`cat ${NGINX_KONG_TEMPLATE} | sed -e 1d -e ${NGINX_KONG_LEN}d`

# Store new proxy block contents in variable
IFS='' read -r -d '' PROXY_BLOCK << EOF
        proxy_pass \$upstream_url;
> if ssl then
        proxy_ssl_certificate_key /usr/local/kong/ssl/client.key;
        proxy_ssl_certificate /usr/local/kong/ssl/client.crt;
> end
EOF

# add prox block to nginx-kong contents, then indent this block
NGINX_KONG_CONTENTS=`echo "$NGINX_KONG_CONTENTS" |  \
    awk -v find='        proxy_pass $upstream_url;' \
    -v replace="$PROXY_BLOCK" \
    's=index($0,find){$0=substr($0,1,s-1) replace substr($0,s+length(find))}1'`

# replace the nginx-conf.conf include with the contents
NGINX_CONTENTS=`echo "$NGINX_CONTENTS" |  \
    awk -v find="    include 'nginx-kong.conf';" \
    -v replace="$NGINX_KONG_CONTENTS" \
    's=index($0,find){$0=substr($0,1,s-1) replace substr($0,s+length(find))}1'`

echo "$NGINX_CONTENTS"
