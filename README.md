# WWWify

WWWify is an nginx config and Docker image for redirecting non-WWW URLs to their WWW counterparts, with HTTPS passthrough.

The main use case is for websites served by load balancers that cannot be added to an apex domain A record (such as when using AWS Load Balancers without Route53 or Alias records). To address this, WWWify is designed to be set up on a single server with a static IP and perform the necessary redirects for any number of websites.

## What does it do?

For HTTP requests:

- Checks `$host`, and if it does not start with `www.` then a 301 is returned with same hostname prepended with `www.`
- Returns a 400 if the URL already contains `www.` (to prevent infinite redirects in the case of DNS misconfiguration)

For HTTPS requests:
- Prereads the server name and proxies the request to the WWWified URL. A 301 redirect becomes the responsibility of the server(s) actually hosting the website.

## Usage

### Docker
```bash
docker run -d -p 80:80 -p 443:443 --restart=always --name wwwify obarrett/wwwify
```

### AWS
Using the CLI:
```bash
# Get the latest Ubuntu 16.04 AMI ID in your default region
IMAGE_ID=$(aws ec2 describe-images --owners 099720109477 --filters \
  Name=root-device-type,Values=ebs \
  Name=architecture,Values=x86_64 \
  Name=name,Values='*hvm-ssd/ubuntu-xenial-16.04-amd64-server*' \
  --query 'sort_by(Images, &Name)[-1].ImageId' --output text
)
aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type t2.micro \
 --user-data file://setup.sh \
 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WWWify}]' 'ResourceType=volume,Tags=[{Key=Name,Value=WWWify}]'
 [--key-name <keypair>] [--subnet-id <subnet ID>] [--security-group-ids <security group ids>] [--security-groups <security groups>]
```

### Linux
`setup.sh` will install and configure nginx for debian-based distros that include apt.

If you already have mainline nginx installed then you can simply copy the contents of `nginx.conf` and reload nginx.
