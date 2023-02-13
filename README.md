Things I have learned:

* nginx config MUST be copied to /etc/nginx/templates/default.conf.template
  * Note: using a template makes this write to /etc/nginx/conf.d/default.conf
  * /etc/nginx/conf.d/default.conf is included by the /etc/nginx/nginx.conf
  * Since a default.conf already will exist using the 80 port, we need to overwrite to not risk a collision that we LOSE
  * https://nginx.org/en/docs/http/request_processing.html
    * Due to how nginx processes requests, it seems that the server_name can allow for two server blocks on the same port
    * In a production environment, this vital configuration should force nginx to use our config, even without overriding default.conf
* Using secrets to hide passwords is fine, but we want our password file to NOT end with a newline
  * For some reason, newlines are very bad in passwords and will result in "password authentication failed for user" errors

