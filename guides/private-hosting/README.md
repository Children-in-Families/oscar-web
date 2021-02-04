# OSCaR Private Hosting Guide

The main purpose of this guide is to help individuals and organizations get up and running with a privately hosted version of OSCaR.

In this guide we will focus on setting up OSCaR in AWS but most of these concepts will work on other cloud platforms. You just need to swap the AWS specific term for the term / product name used in your platform.

For example, you will see an AWS service called RDS. This is a database hosting service from AWS and if you are running on Google Cloud, AZURE, Oracle Cloud, Digital Ocean or any other cloud hosting provider, they will also have a database as a service offering which you can use.

Please also note that we will not dive too deep into the specifics of AWS and will rather let the reader determine via the AWS documentation certain specifics. For example, we will not explain how to create a new AWS account or setup a new IAM user for running the services. This (and other AWS speciifcs) are all widely documented and covered by AWS and certified AWS organizations.

Having said that the underlying technology will always be the same and we will be using:

* Ubuntu Server 20.04 LTS 64-bit (x86)
* Docker Runtime  (19.03.14)
* Docker Compose (1.27.4)
* Postgres 11.8
* Mongo DB 4.2.10

So with that, lets get started and setup OSCaR in AWS.

### Video Tutorial

I've made a video walkthough of this guide which you can view [here](https://www.youtube.com/watch?v=HGyn8rWH-24).

### Setup OSCaR on EC2

OSCaR will run on Ubuntu Linux. So in AWS we will use EC2 for this. You need to log into your AWS and do the following:

1. Go to [EC2 Dashboard](https://ap-southeast-1.console.aws.amazon.com/ec2/v2/home)
1. Click on 'Launch Instnaces' button.
1. Select the Amazon Machine Image (AMI) to use. We recommend `Ubuntu Server 20.04 LTS 64-bit (x86)`
1. Select an instnace size that you would like to use. We recommend at least a `t3.medium`.
1. You will need to have port 3000 open to accept HTTP connections and port 22 for SSH. Make sure to consider security aspects and only allow port 22 for your own IP address!
1. You will need to have an EBS drive of at least 20GB or more.

With the above you should be able to launch a new EC2 instance running Ubuntu Linux.

Now you need to SSH into the instance by following the instructions provided in AWS.

## Setup developer account

Once you have logged into your instance using the instructions provided by AWS you can create a new developer account on the server that you will use going forward.

1. Add your public ssh key to authorized keys file on the server (usually found in `~/.ssh/authenticated_keys`)
1. Create a new developer account using the [create-user.sh](./create-user.sh) script
1. Update the server hostname so you know where you are: `hostnamectl set-hostname oscarprivatedemo`

## Installing Docker on Ubuntu

```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
```

### Running Docker without Sudo

```
sudo usermod -aG docker ${USER}
su - ${USER}
```

### Install Docker Compose

We will install Docker Compose 1.27.4

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Add Docker Compose as an alias in bashrc

Add an alias of `dc` for running `docker-compose` to your ~/.bashrc file:

```
alias dc='docker-compose'
```

### Clone OSCaR Repo

Note you will need an account at Github.

```
git clone https://github.com/DevZep/oscar-web.git
```

### Install Make

```
sudo apt install make
```

### Run the application using Docker Compose

OSCaR is packaged with a number of make commands to start up the services.

```
cd oscar-web
git checkout stable
dc up --no-deps app db mongo
```

### Compile the static assets

Connect to the running app container

```
docker exec -it app bash
```

Compile the assets using the following command:

```
rake assets:precompile
```
### Add a new sub-domain to your private domians DNS record to point your IP to your private server

OSCaR needs a domain to run and a sub-domain for each tenant. If you have just one tenant then that is all you need. For this demo the tenant is called 'dev' and the sub-domain must be called 'dev'.

1. Add an 'A Record' to your Route 53 table using your own domain and the sub-domain you want to use for your tenant / instance in your private version of OSCaR. In this private demo the sub-domain is 'dev' and you need to point to the public IP of the instance.

### Login to OSCaR

Open your new 'dev' instance via this url (replace 'YOUR-DOMAIN' with your own private domain that you own): `http://dev.YOUR-DOMAIN.com:3000/users/sign_in`

The sample account username and password is `team@oscarhq.com` password is `123456789`. Note this is obviously NOT SECURE!

### Next steps

Now that you have the demo version running in your private cloud you will want to make a number of changes since as it is now its not ready to be used by your own organization. Some of the changes we suggest that you make:

1. Add an SSL to your domain so that you can make secure requests to your instance using `https`
1. Open port 443 and use a reverse proxy server to forward requests to the Docker containers on the server. We recommdn using Nginx for that.
1. Create your own new private tenant and remove the 'dev' tenant used in the the private demo. That way you can add your own useers with their own secure passwords as well as fully customize your isntance using your own logo and other settings.
1. Use a hosted database service for your data rather than Docker running on EC2. This will mean better security and separaton of your data as well as backups and other improvments like data encryption. We recommend using AWS RDS.
1. Use a hosted service for Mongo DB
1. Use a scalable solution for running rails either by using Passenger on EC2 or using a Docker Orchistration service such as AWS ECS Fargate or EKS (Kubernetes)
1. Use a CDN for serving the static assets. This will improve efficiency of your app and make the experience much better for users of your private system. We recommend using S3.
1. Run the application as a service and provide monitoring and error logging tools for improved maintenance and visibility

### Support

All of the above steps are able to be comleted by an expereinced DevOps engineer. Anything that is specific for OSCaR configuration (such as settiing up a new Tenant) will be provided in our README. If anything is missing from our documentation or you have any questions please do not hesitate to reach out to us.

### Troubleshooting

Try checking our [Developer Troubleshooting Guide](../developer/README.md#troubleshooting)