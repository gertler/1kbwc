# 1KBWC
1KBWC is a web server project using Docker and Vapor to build the backend while using services like AWS S3 to collect data.

For storing persistent data like users, this project uses Postgres DB, running as a Docker container; credentials for creating/connecting to this DB are stored as variables that can be set before running. See [Basic Usage](#basic-usage)

## Prerequirements
You'll need a few dependencies before you get started:
* Docker
  * Mac (I recommend just downloading from https://www.docker.com/products/docker-desktop/)
    * Alternative: `brew cask install docker`
  * Linux:
  ```bash
  sudo apt install docker.io &&
  # Allow user to run docker without sudo
  sudo usermod -aG docker $USER
  ```
* Docker Compose
  * Mac: Install Docker Desktop (see Docker)
  * Linux:
  ```bash
  sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m) -o /usr/local/bin/docker-compose &&
  # Set executable permissions
  sudo chmod +x /usr/local/bin/docker-compose &&
  docker-compose version
  ```
* Network
  * Your computer will need to be publicly reachable at ports 80 and 443 for the webserver to work
  * You will also want your domain to be properly setup with a corresponding "A Record" pointing to your public IP Address
* AWS
  * In order to use S3, which is the file storage solution used here, you'll need an AWS account and IAM Role for reading and writing data to an S3 bucket
  * You need an S3 bucket capable of storing your files that will be uploaded

## Basic Usage
### Step #0 - Environment and Configuration
You should obtain an SSL (technically TLS, but they're the "same") certificate before running this server. The importance is to encrypt data to and from the web server for security purposes, while also making browsers happier when presenting the website. This can be done in a few ways, but the simplest and cheapest is to use **Let's Encrypt**, which can be accessed via the [Certbot tool](https://certbot.eff.org).
Place the certs you get from running that tool into the `./nginx/certbot/` folder.

#### Fill in all of your secret information into `./secrets`
* `admin_user.txt`: The username to be set up as an admin user
* `admin_password.txt`: The password for the admin user
* `pg_database.txt`: The name of your postgres database
* `pg_user.txt`: The username to connect to your postgres database
* `pg_password.txt`: The password to connect to your postgres database
* `aws_access_key.txt`: The AWS IAM Role Access Key for S3 read/write
* `aws_secret_access_key.txt`: The AWS IAM Role Secret Access Key for S3 read/write

#### Fill in environment variables into `env/.env.*` files
* `.env.prod`
  * `S3_BUCKET_NAME`: The name of the S3 bucket to store files in
  * `S3_REGION`: The region for the S3 bucket (i.e., us-east-1)
* `.env.nginx.prod`
  * `SERVER_NAME`: The domain name that resolves to your computer's IP address ("localhost" if running in local development environment)
  * `HTTP_PORT`: The port to use for HTTP traffic (you should choose **80** unless you have a specific reason not to)
  * `HTTPS_PORT`: The port to use for HTTPS traffic (you should choose **443** unless you have a specific reason not to)
  * `SSL_CERT`: The **internal** (for the nginx Docker container) path to your SSL certificate; this should be the path to your cert within the `nginx/certbot` folder
    * Since we are using Docker volumes, nginx/certbot is mapped to `/etc/letsencrypt/`
    * Example:
    ```bash
    # Say your folder structure looks like...
    ./
    docker-compose.yml
    nginx/
    |  certbot/
    |  |  my-cert.pem
    ...
    # Then, SSL_CERT should be: my-cert.pem
    # And, the final cert location will be: /etc/letsencrypt/my-cert.pem
    ```
  * `SSL_KEY`: The **internal** (for the nginx Docker container) path to your SSL key; the location should be the same as `SSL_CERT` (See above for details)


### Step #1 - Testing the Server Locally
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml \
  up --build --abort-on-container-exit
```


## Understanding the Folder Structure
The root folder of this project contains a lot of subfolders and files. Here are the brief explanations for each file/folder:
* `env/` stores files like .env.prod or .env.nginx.dev that contain Environment variables read by Docker and used when running containers
* `nginx/` contains all the configuration needed to manage the nginx reverse-proxy
* `Public/` is where all static files being served are stored (css, js, favicon.ico, etc.)
* `Resources/` contains all the dynamic HTML content templates rendered with [Leaf](https://docs.vapor.codes/leaf/getting-started/)
* `secrets/` is where to put text files containing environment variables for use alongside Docker secrets
  * See [Docker Swarm Secrets](https://docs.docker.com/engine/swarm/secrets/) and [Docker Secrets with Compose](https://docs.docker.com/compose/compose-file/#secrets)
* `Sources/` contains all the Swift source code for running the Vapor app including API routes and managing the [ORM](https://en.wikipedia.org/wiki/Object–relational_mapping) between server and database; Vapor's ORM framework of choice is [Fluent](https://docs.vapor.codes/fluent/overview/), which handles data models in a [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) fashion
* `Tests/` currently sees no use, but is left to make sure Vapor runs smoothly
* `docker-compose.dev.yml` is the config file for running the app in a development environment; it is NOT meant to be used in production
* `docker-compose.prod.yml` is the config file for running the app in a production environment
* `docker-compose.yml` is the config file for each container and helper command (vapor app, nginx, postgres, migrate, etc.)
* `Dockerfile` is the main Dockerfile used to compile and build the vapor app image
* `package.json` is the Javascript package file for managing any node.js dependencies used; see [node.js dependencies](#nodejs-dependencies)


## Node.js Dependencies?
As implied by the `package.json` file in the root directory, this project makes *slight* use of node/npm to install some javascript packages locally so they can be referenced later by the frontend. One such package is [fabric.js](http://fabricjs.com), which acts as a wrapper for `<canvas>` tags to allow easy drawing capabilities right on the browser.

Since these packages are equitable to a statically linked library, this means we need to use the dist, or distribution, versions of the package when installed via `npm install`. For instance, plain client-side javascript cannot do something like:

❌
```js
var events = require('events');
var eventEmitter = new events.EventEmitter();
```
However, some packages provide an alternative if the user only wants a static javascript file to import instead of using with node. Those packages can be found when running the server in the `/static/` endpoint. For example:

✅
```html
<script src="/static/fabric/dist/fabric.js"></script>
```

### Browserify?
https://browserify.org

Currently, this project does **NOT** use browserify to allow for easier access to packages. When initially programming this part, I was oblivious to this as an option for essentially adding node-like behavior to client-facing javascript. The intent here would be to allow us to simply `require('<package>');` packages instead of needing to use pre-browser-friendly versions of packages as described above. In the future, if the node dependencies piled up, then this would be good to investigate possibly integrating.

...
...
...

## Random Things I Have Learned:

* In order to update the Swift version, you need to update the Dockerfile as well as the Package.swift to keep both aligned
* nginx config MUST be copied to /etc/nginx/templates/default.conf.template
  * Note: using a template makes this write to /etc/nginx/conf.d/default.conf
  * /etc/nginx/conf.d/default.conf is included by the /etc/nginx/nginx.conf
  * Since a default.conf already will exist using the 80 port, we need to overwrite to not risk a collision that we LOSE
  * https://nginx.org/en/docs/http/request_processing.html
    * Due to how nginx processes requests, it seems that the server_name can allow for two server blocks on the same port
    * In a production environment, this vital configuration should force nginx to use our config, even without overriding default.conf
* Using secrets to hide passwords is fine, but we want our password file to NOT end with a newline
  * For some reason, newlines are very bad in passwords and will result in "password authentication failed for user" errors
* For TTS JSON, we MUST have the duplicate copies of "CustomDeck" so that images will appear when cards are IN the deck as well as separate entities
