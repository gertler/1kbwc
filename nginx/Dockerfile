FROM nginx:latest
RUN mkdir /etc/nginx/templates
COPY ./nginx.conf.template /etc/nginx/templates/
# Used in config for ssl_dhparam option in https server
RUN curl https://ssl-config.mozilla.org/ffdhe2048.txt > /etc/nginx/dhparam.pem
