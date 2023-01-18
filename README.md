Things I have learned:

* nginx config MUST be copied to /etc/nginx/templates/default.conf.template
  * Note: using a template makes this write to /etc/nginx/conf.d/default.conf
  * /etc/nginx/conf.d/default.conf is included by the /etc/nginx/nginx.conf
  * Since a default.conf already will exist using the 80 port, we need to overwrite to not risk a collision that we LOSE
* Using secrets to hide passwords is fine, but we want our password file to NOT end with a newline
  * For some reason, newlines are very bad in passwords and will result in "password authentication failed for user" errors

