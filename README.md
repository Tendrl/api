# Tendrl API
## Installation
```shell
$ rbenv install 2.0.0-p647 # Install ruby 2.0.0
$ gem install bundler
$ bundle install
```
## Development Environment
Steps to set up the Tendrl API for development.

#### Tendrl Definitions
The API needs the proper Tendrl definitions yaml file to generate the attributes and actions. You can either download it or use the one from the fixtures to explore the API.
```shell
  $ cp spec/fixtures/sds/tendrl_definitions_gluster-3.8.3.yaml config/sds/tendrl_definitions_gluster-3.8.3.yaml 
```
 #### Connecting to Etcd
 Copy the sample config/etcd.sample.yaml file to config/etcd.yml and add your Etcd connection configuration to the yaml file.
 ```shell
  $ cp config/etcd.sample.yml to config/etcd.yml
 ```
 #### Seed the Etcd instance (Optional). 
 The script will seed the Etcd instance with mock cluster data and print a cluster uuid which can be used to make API requests.
 ```shell
  $ rake etcd:seed # Seed the local store with cluster
 ```
#### Start the development server  
```shell
  $ bundle exec shotgun
```

## Test Environment
The test environment does not need the local Etcd instance to run the tests.
```shell
  $ bundle exec rspec
```
