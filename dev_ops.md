## DevOps

SSH in to the DigitalOcean server.

```
// username: soundblab
// password: blab@123#
// ssh_access:
$ ssh soundblab@craftacademy.se

// Make sure ssh public key is added to server
```

root directory: `/var/www/html/ca-certificates`

## Deployment
We are deploying using Capistrano

Your `.env` file need to contain the right information

S3_BUCKET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=us-east-1
SERVER_URL=https://certificates.craftacademy.se/verify/
BITLY_USERNAME=
BITLY_API_KEY=
BITLY_TOKEN=
DATABASE_URL=

# SMTP Settings
SMTP_ADDRESS=
SMTP_PORT=
SMTP_DOMAIN=certificates.craftacademy.se
SMTP_USERNAME=ca-certificates
SMTP_PASSWORD=
SMTP_FROM=thomas@craftacademy.se

SSH_USER=soundblab
PROD_SERVER=craftacademy.se
PROD_PATH=/var/www/html/ca-certificates

GH_USER=
GH_PASSWORD=
```

Deploy with thefollowingg command
```
$ cap production deploy --trace
```