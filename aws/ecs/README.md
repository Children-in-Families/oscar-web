# AWS ECR

This readme is about running OSCaR in AWS ECR Fargate as Docker Container instance.

## Deployment

There are two steps:

1. Run `cap staging deploy` as usual (if using Docker start the container first `docker run -v ~/.ssh:/root/.ssh -it --entrypoint bash oscar-staging:latest`).
1. SSH into the staging build server, cd into the `current` folder and run `./aws/ecs/deploy-oscar-staging-ecs.bash`.

## (Optional) check the contents of the image on the server

If you want to confirm the image was built correctly you can instpect its contents by running this command:

```
docker run -it --entrypoint bash oscar-staging:latest
```

## (Optional) Update the task definition associated with the service

If you want to deploy the service with an updated task definition then run the following command replasing `UPDATED_TASK_DEFINITION` with your task definition name and version.

```
aws ecs update-service --cluster oscar-staging --service oscar-staging-service --task-definition UPDATED_TASK_DEFINITION --force-new-deployment --region ap-southeast-1
```

## Maually force stopping a deployement

Sometimes its necessary to stop a deployment, using the following command:

```
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --no-force-new-deployment --region ap-southeast-1
```

## Install Docker on Ubuntu

Follow [these instructions](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) if you need to install Docker service on Ubuntu.

## Install AWS CLI on Ubuntu

Follow [these instructions](https://linuxhint.com/install_aws_cli_ubuntu/) if you need to install AWS CLI on Ubuntu.
