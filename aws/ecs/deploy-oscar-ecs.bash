# load env vars for docker commands
cd /var/www/oscar-web/current
export $(cat .env | sed 's/#.*//g' | xargs)

# login AWS ECR
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin $IMAGE_REPO_URL

# build the docker image and push to an image repository
docker build -t $IMAGE_NAME:latest .
docker tag $IMAGE_NAME:latest $IMAGE_REPO_URL:latest
docker push $IMAGE_REPO_URL:latest

# update an AWS ECS service with the new image
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment --region ap-southeast-1