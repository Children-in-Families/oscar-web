[ ![Codeship Status for rotati/cif-web](https://codeship.com/projects/1e6acaa0-7c8c-0133-2482-26ef8f2c3d05/status?branch=master)](https://codeship.com/projects/119967)

## README

### Installation

* Postgres
* Ruby(2.2.0)
* Rubygems
* Bundler
* Git

Once you have installed the above, clone this repository and get into the directory and run `bundle` or `bundle install` to install all the required gems. Then follow the instructions below to get things going!

### Configuration

> create .env file
  <br> Example. copy content from .env.example

### Import Data from XLS

`````````````````````````````````
`````````````````````````````````
``` rake import:cif           ```
`````````````````````````````````
`````````````````````````````````


### Start Rails

> rails s (for rails server)
  <br> rails c (for rails console)

### Run some inital command

> rake db:create (to create database)
  <br> rake db:migrate
  <br> rake db:reset (to reset database)
  <br> rake db:drop (to drop database)

### Run Import

** Before these command to import data from spreadsheet**

`````````````````````````````````
`````````````````````````````````
``` rake import:cif           ```
`````````````````````````````````
`````````````````````````````````

### Deploy
** Run command below if you want to deploy to staging server directly. Anyway codship also deploy while all test pass **
> cap staging deploy

> cap staging deploy:mobile