server {
    listen {{ .interface }}:{{ . port }} default_server;

    include /etc/nginx/includes/server_params.conf;
    include /etc/nginx/includes/proxy_params.conf;

    allow   172.30.32.2;
    deny    all;

    location / {
        allow   172.30.32.2;
        deny    all;

        proxy_pass http://backend;
    }
}
