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
    
```yaml
sudo: required
services:tra
  - docker
before_install:
  - openssl aes-256-cbc -K $encrypted_98f85f8775b8_key -iv $encrypted_98f85f8775b8_iv -in service-account.json.enc -out service-account.json -d
  - curl https://sdk.cloud.google.com | bash > /dev/null;
  - source $HOME/google-cloud-sdk/path.bash.inc
  - gcloud components update kubectl
  - gcloud auth activate-service-account --key-file service-account.json

script:
  - docker run stephengrider/react-test npm test -- --coverage
```
