### Set up travis & gcloud

- 1) Install gcloud to travis-local
  - curl https://sdk.cloud.google.com | bash > /dev/null;
  - source $HOME/google-cloud-sdk/path.bash.inc
  - gcloud components update kubectl
- 2) Login gcloud via encrypted_service_account.json
  - Go to https://console.cloud.google.com/iam-admin/iam
  - Click **Service accounts**
  - Create credential json file with **Kubernetes Engine Admin** role
  - Encrypt with ruby gem **travis**
    + docker run -it -v $(pwd):/app ruby:2.3 sh
    + make sure service-account.json under your app
    + gem install travis
    + travis login
    + travis encrypt-file service-account.json -r lucas2804/k8s_gcloud (-r: repository on travis-ci)

```bash
Please add the following to your build script (before_install stage in your .travis.yml, for instance):

    openssl aes-256-cbc -K $encrypted_98f85f8775b8_key -iv $encrypted_98f85f8775b8_iv -in service-account.json.enc -out service-account.json -d

Pro Tip: You can add it automatically by running with --add.

Make sure to add service-account.json.enc to the git repository.
Make sure not to add service-account.json to the git repository.
Commit all changes to your .travis.yml.
``` 

### II - Setup docker images

- Setup DOCKER_ID and DOCKER_PASSWORD on travis-ci.org (https://travis-ci.org/lucas2804/k8s_gcloud/settings)
- login as **echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin**

```bash
docker build -t lucdang/multi-client:latest -f ./client/Dockerfile ./client
docker build -t lucdang/multi-server:latest -f ./server/Dockerfile ./server
docker build -t lucdang/multi-worker:latest -f ./worker/Dockerfile ./worker

docker push lucdang/multi-client:latest 
docker push lucdang/multi-server:latest 
docker push lucdang/multi-worker:latest
```   
    
```yaml
sudo: required
services:
  - docker
cache:
  directories:
    # We cache the SDK so we don't have to download it again on subsequent builds.
    - $HOME/google-cloud-sdk
env:
  global:
    # Do not prompt for user input when using any SDK methods.
    - CLOUDSDK_CORE_DISABLE_PROMPTS=1
before_install:
  - openssl aes-256-cbc -K $encrypted_98f85f8775b8_key -iv $encrypted_98f85f8775b8_iv -in service-account.json.enc -out service-account.json -d
  - if [ ! -d "$HOME/google-cloud-sdk/bin" ]; then rm -rf $HOME/google-cloud-sdk; export CLOUDSDK_CORE_DISABLE_PROMPTS=1; curl https://sdk.cloud.google.com | bash; fi

  - source /home/travis/google-cloud-sdk/path.bash.inc
  - gcloud version
  - gcloud components update kubectl
  - gcloud auth activate-service-account --key-file service-account.json
  - gcloud config set project lucskylab01
  - gcloud config set compute/zone us-central1-a
  - gcloud container clusters get-credentials lucskylab01 #(lucskylab01: cluster_name)
  - echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  - docker build -t lucdang/react-test -f ./client/Dockerfile.dev ./client

script:
  - docker run lucdang/react-test  npm test -- --coverage

deploy:
  provider: script
  script: bash ./deploy.sh
  on:
    branch: master
```
