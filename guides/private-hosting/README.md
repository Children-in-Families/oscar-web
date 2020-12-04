## OSCaR Private Hosting Guide

The main purpose of this guide is to help individuals and organizations get up and running with a privately hosted version of OSCaR.

In this guide we will focus on setting up OSCaR in AWS but most of these concepts will work on other cloud platforms. You just need to swap the AWS specific term for the term / product name used in your platform.

For example, you will see an AWS service mentioend quite a bit which is RDS. This is a database hosting service from AWS and if you are running on Google Cloud, AZURE, Oracle Cloud, Digital Ocean or any other cloud hosting provider, they will also have a database as a service offering which you can use.

Please also note that we will not dive too deep into the specifics of AWS and will rather let the reader determine via the AWS documentation certain specifics. For example, we will not explain how to create a new AWS account or setup a new IAM user for running the services. This (and other AWS speciifcs) are all widely documented and covered by AWS and certified AWS organizations.

Having said that the underlying technology will always be the same and we will be using:

* Postgres (Version 12x)
* Ubuntu Linux (Version 20.04)
* Docker Runtime (Version)

So with that, lets get started and setup OSCaR in AWS.

### Setup OSCaR on EC2

OSCaR will run on Ubuntu Linux. So in AWS we will use EC2 for this. You need to log into your AWS and do the following:

1. Go to EC2 Dashboard
1. Go to Launch New Instnace
1. Select an instnace size that you would like to use. We recommend at least a `t3.medium`.
1. Select Ubuntu Linux image
1. You will need to have port 80 open to accept HTTP connections and port 22 for SSH. Make sure to consider security aspects and only allow port 22 for your own IP address!
1. You will need to have an EBS drive of at least 20GB or more.

With the above you should be able to launch a new EC2 instance running Ubuntu Linux.

Now you need to SSH into the instance by following the instructions provided in AWS.

### Run OSCaR in Docker

Once you have SSH into the instance you will need to do the following:

1. Install the [latest version of Docker runtime](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04).
1. You then need to build and run the Docker image of OSCaR
1. You will need to install MongoDB
1. You need to configure the ENVIRONMENT vars of OSCaR to point to MongoDB

### Setup OSCaR Database in RDS

OSCaR uses Postgres as its primary database. We recomend using RDS.

1. Go to RDS and create a new database server. A `t2.small` instnance should be fine with all them minimal settings.
1. Make sure to allow incomming connections on the postgres port (5432) from the security group assigned to the OSCaR server.
1. Update the database specific environment variables in OSCaR on ECT
1. Now you can test the connection to the database by running the database migrations for the application.

### Update Route 53 to point your domain to your server

OSCaR needs a domain to run and a sub-domain for each tenant. If you have just one tenant then that is all you need.

1. Add an 'A Record' to your Route 53 table using your own domain and the subdimain you want to use for your tenant / instance in your private version of OSCaR.
1. Now open your browser and visit the the site.

### Support

If you require any technical support, please reach out to the team at [DevZep](www.devzep.com).