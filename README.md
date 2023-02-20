# 1KBWC
1KBWC is a web server project using Docker and Vapor to build the backend while using services like AWS S3 to collect data.
For storing persistent data like users, 

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
#### Fill in all of your secret information into `./secrets`
* `pg_database.txt`: The name of your postgres database
* `pg_user.txt`: The username to connect to your postgres database
* `pg_password.txt`: The password to connect to your postgres database
* `aws_access_key.txt`: The AWS IAM Role Access Key for S3 read/write
* `aws_secret_access_key.txt`: The AWS IAM Role Secret Access Key for S3 read/write

#### Fill in environment variables into `.env.*` files
* `S3_BUCKET_NAME`: The name of the S3 bucket to store files in
* `SERVER_NAME`: The domain name that resolves to your computer's IP address ("localhost" if running in local development environment)

### Step #1 - Testing the Server Locally
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml \
  up --build --abort-on-container-exit
```




...
...
...

## Things I have learned:

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
