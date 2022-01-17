#!/usr/bin/env bash

export REGION="europe-west1"

export ICON="\U1F4E2"
export OK="  \U2705"
export NOK="  \U274C"


echo -e "${ICON} grant storage object viewer role to default cloudbuild service account"
PROJECT_NUMBER=$(gcloud projects list \
  --format="value(projectNumber)" \
  --filter="projectId=${PROJECT_ID}")

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role "roles/storage.objectViewer" \
  > /dev/null 2> /dev/null

echo -e "${ICON} grant appengine deployer role to default cloudbuild service account"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role "roles/appengine.deployer" \
  > /dev/null 2> /dev/null

echo -e "${ICON} allow the default cloud build service account to act as the default app engine service account"
gcloud iam service-accounts add-iam-policy-binding \
    ${PROJECT_ID}@appspot.gserviceaccount.com \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

echo -e "${ICON} grant roles/secretmanager.secretAccessor to default app engine service account"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${PROJECT_NUMBER}@appspot.gserviceaccount.com" \
  --role "roles/secretmanager.secretAccessor" \
  > /dev/null 2> /dev/null

echo -e "${ICON} set region globally to be used by cloud functions"
gcloud config set functions/region ${REGION} >/dev/null 2>/dev/null

echo -e "${ICON} enable required gcp api's"
gcloud services enable --project "${PROJECT_ID}" \
  secretmanager.googleapis.com \
  appengine.googleapis.com \
  cloudbuild.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com

