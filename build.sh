#!/bin/bash -e

export CURR_JOB="buildApp"
export HUB_ORG="chetantarale"
export IMAGE_NAME="sampleapp"
export IMAGE_TAG=latest

export RES_REPO="sampleapp_repo"
export RES_IMAGE="app-img"
export RES_MICROBASE_IMAGE="microbase_img"

export RES_REPO_UP=$(echo $RES_REPO | awk '{print toupper($0)}')
export RES_REPO_COMMIT=$(eval echo "$"$RES_REPO_UP"_COMMIT")
export RES_DOCKERHUB_INTEGRATION=dockerhub

set_context() {
  echo "CURR_JOB=$CURR_JOB"
  echo "HUB_ORG=$HUB_ORG"
  echo "IMAGE_NAME=$IMAGE_NAME"
  echo "IMAGE_TAG=$IMAGE_TAG"
  echo "RES_REPO=$RES_REPO"
  echo "RES_IMAGE=$RES_IMAGE"
  echo "RES_IMAGE_VER_NAME=$RES_IMAGE_VER_NAME"
  echo "RES_REPO_UP"="$RES_REPO_UP"
  echo "RES_REPO_COMMIT"="$RES_REPO_COMMIT"
}

dockerhub_login() {
  echo "Logging in to Dockerhub"
  echo "----------------------------------------------"

  local creds_path="IN/$RES_DOCKERHUB_INTEGRATION/integration.json"

  find -L "IN/$RES_DOCKERHUB_INTEGRATION"
  local username=$(cat $creds_path \
    | jq -r '.username')
  local password=$(cat $creds_path \
    | jq -r '.password')
  local email=$(cat $creds_path \
    | jq -r '.email')
  echo "######### LOGIN: $username"
  echo "######### EMAIL: $email"
  sudo docker login -u $username -p $password -e $email
}

build_tag_push_image() {
  echo "Starting Docker build for" $HUB_ORG/$IMAGE_NAME:$IMAGE_TAG
  cd ./IN/$RES_REPO/gitRepo
  ls
  sed -i -- 's/\[VERSION\]/'$((APPIMG_VERSIONNUMBER+1))'/g' views/index.ejs
  cat views/index.ejs
  sudo docker build -t=$HUB_ORG/$IMAGE_NAME:$IMAGE_TAG.$((APPIMG_VERSIONNUMBER+1)) .
  sudo docker push $HUB_ORG/$IMAGE_NAME:$IMAGE_TAG.$((APPIMG_VERSIONNUMBER+1))
  echo "Completed Docker build for" $HUB_ORG/$IMAGE_NAME:$IMAGE_TAG.$((APPIMG_VERSIONNUMBER+1))
}

create_image_version() {
  echo "Creating a state file for" $RES_IMAGE
  echo versionName=$IMAGE_TAG.$((APPIMG_VERSIONNUMBER+1)) > /build/state/$RES_IMAGE.env
  echo APPIMG_VERSIONNUMBER=$((APPIMG_VERSIONNUMBER+1)) >> /build/state/$RES_IMAGE.env
  echo "Completed creating a state file for" $RES_IMAGE
}

main() {
  set_context
  dockerhub_login
  build_tag_push_image
  create_image_version
}

main
