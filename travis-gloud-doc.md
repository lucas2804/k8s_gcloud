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

```yaml
sudo: required
services:
  - docker
before_install:
  - curl https://sdk.cloud.google.com | bash > /dev/null;
  - source $HOME/google-cloud-sdk/path.bash.inc
  - gcloud components update kubectl
  - gcloud auth activate-service-account --key-file service-account.json

script:
  - docker run stephengrider/react-test npm test -- --coverage
```
