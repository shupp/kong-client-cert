# Overview
kong-client-cert is a way to enable a client certificate when communicating from kong to your proxied api server.  If **SECRET_CLIENT_KEY** and **SECRET_CLIENT_CERT** environment variables are set in this container, their contents get written to client.key and client.crt in /usr/local/kong/ssl, respectively.  A custom nginx.conf file is generated to set the following directives:

    proxy_ssl_certificate_key /usr/local/kong/ssl/client.key;
    proxy_ssl_certificate /usr/local/kong/ssl/client.crt;

Your upstream API will also need to verify the client key for it to be useful.  You can do so by placing your CA cert in /etc/nginx/certs/ca.crt, and then including the follwing directives in your API server config (assuming nginx), near the _ssl_certificate_ and _ssl_certificate_key_ directives:

    ssl_client_certificate /etc/nginx/certs/ca.crt;
    ssl_verify_client optional;

This will make ssl client verification optional.  Set _optional_ to _on_ to make them required.  Using [_ssl_client_certificate_](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_client_certificate) means that the client certificate must be signed with the one in /etc/nginx/certs/ca.crt.

To pass the verification information to your application, you can do so in the fastcgi_param directives:

        fastcgi_param  VERIFIED $ssl_client_verify;
        fastcgi_param  DN $ssl_client_s_dn;

Lastly, here's an example call to docker-compose with your environment variables set from key/crt files:

    SECRET_CLIENT_KEY=`cat client.key` \
    SECRET_CLIENT_CERT=`cat client.crt` docker-compose up

Note that the _client.key_ file has no password set.

# Caveats

This proxy_ssl_certificate directive is global to all apis proxied by this kong instance.  In addition, I haven't yet tested what happens when the http client to kong supplies its own certificate.. is that dropped between kong and the API?

# Links

* [Kong mailing list thread on the topic](https://groups.google.com/forum/#!searchin/konglayer/client$20certificate%7Csort:relevance/konglayer/Hsr9-8ZM-28/AN7Bo_iHAAAJ)
* [Kong feature request](https://github.com/Mashape/kong/issues/1547)
* [Nginx client certificate tutorial](http://blog.nategood.com/client-side-certificate-authentication-in-ngi)
* [Nginx SSL documentation](http://nginx.org/en/docs/http/ngx_http_ssl_module.html)

