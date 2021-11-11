server {
    listen {{ .interface }}:{{ .port }} default_server;

    include /etc/nginx/includes/server_params.conf;
    include /etc/nginx/includes/proxy_params.conf;

    allow   172.30.32.2;
    deny    all;

    location ~* /session$ {
        proxy_set_header Content-Type application/x-www-form-urlencoded;
        proxy_pass http://backend;
    }

    location / {
        proxy_set_header Content-Type application/json;
        proxy_pass http://backend;
    }
}
