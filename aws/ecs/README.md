# AWS ECR

This readme is about running OSCaR in AWS ECR Fargate as Docker Container instance.

If your interested in how this is setup, there is a tutorial on the AWS website for [Creating a cluster with a Fargate task using the Amazon ECS CLI](https://docs.amazonaws.cn/en_us/AmazonECS/latest/userguide/ecs-cli-tutorial-fargate.html)

## Deployment

There are two steps:

1. Run `cap staging deploy` OR `cap production deploy` as usual.
1. SSH into the staging OR production build server, cd into the `current` folder and run `./aws/ecs/deploy-oscar-ecs.bash`.

## Running cap...deploy from within Docker

If using Docker start the container first and then run the `cap...deploy` command from within the container:

```
docker run -v ~/.ssh:/root/.ssh -it --entrypoint bash oscar-staging:latest
docker run -v ~/.ssh:/root/.ssh -it --entrypoint bash oscar-production:latest
```

## (Optional) check the contents of the image on the server

If you want to confirm the image was built correctly you can instpect its contents by running this command:

```
docker run -it --entrypoint bash oscar-staging:latest
docker run -it --entrypoint bash oscar-production:latest
```

## (Optional) Register / update a task definition file

Sometimes the actual task definition version needs to be updated like so which creates a new TD version for you:

```
aws ecs register-task-definition --cli-input-json file://aws/ecs/private/oscar-staging-td.json
aws ecs register-task-definition --cli-input-json file://aws/ecs/private/oscar-production-td.json
```

## (Optional) Update the task definition associated with the service

If you want to deploy the service with an updated task definition then run the following command replasing `UPDATED_TASK_DEFINITION` with your task definition name and version.

```
aws ecs update-service --cluster OSCaR-Staging --service oscar-staging-service --task-definition UPDATED_TASK_DEFINITION --force-new-deployment --region ap-southeast-1
aws ecs update-service --cluster OSCaR-Production --service oscar-production-service --task-definition UPDATED_TASK_DEFINITION --force-new-deployment --region ap-southeast-1
```

Add `--desired-count` to set the desired count if you want to change that from its current setting.

## Maually force stopping a deployement

Sometimes its necessary to stop a deployment, using the following command:

```
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --no-force-new-deployment --region ap-southeast-1
```

## Delete Docker Image Cache

Docker creates a new image diff each time a deployment is made. These images are in an untagged state so to remove all untagged images, simply run:

```
docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}")
```

## Install Docker on Ubuntu

Follow [these instructions](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) if you need to install Docker service on Ubuntu.

## Install AWS CLI on Ubuntu

Follow [these instructions](https://linuxhint.com/install_aws_cli_ubuntu/) if you need to install AWS CLI on Ubuntu.
s