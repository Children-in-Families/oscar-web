## OSCaR Developer Guide

The main purpose of this guide is to help developers get up and running with a development environment of OSCaR.

### Requirements

- Docker Desktop (latest stable version for your platform)

### Getting Started

Given that we are using Docker, then most common development tasks you will just need the _core services_ which are essentially the OSCaR App Service (Rails) and the OSCaR Database Service (Postgres). To spin these services up only, use the following `make` command:

```
make start_core
```

This starts a Rails, Postgres and Webpack container. If you need the Mongo container running then execute the following command in a separate terminal:

```
make start_mongo
```

See the project [Makefile](./Makefile) for a list of all the available commands.

Once the containers have fired up open a web browser and navigate to [http://localhost:3000](http://localhost:3000) to open the app. To login, click on the 'dev' organizations logo (there should only be the one logo) and the username (email) is any of the users (listed in the 'users' sheet) of the [lib/devdata/dev_tenant.xlsx](lib/devdata/dev_tenant.xlsx) spreadsheet with the password set to `123456789`.

_NOTE_ If this is the first time you have run this you may need to stop the containers and run it again!

### Running the tests

To run the tests using Docker you can do the following:

```
make start_core
```

## Debugging using Pry

If you want to debug the Rails application using Pry you need to attach to the container running Rails first. To do that in a new terminal window run:

```
make rails_attach
```

Now when your code runs and gets to the `binding.pry` line it will halt and a Pry REPL session will be available in the terminal window where you are attached.

When you have finished dubugging just type `exit` in the Pry REPL session as you normally would. Keep this terminal attached for convenience if you need to use Pry again.

NOTE: To detach the tty **without also terminating the Rails container**, you need to use the escape sequence **Ctrl+P** followed by **Ctrl+Q**.

## Troubleshooting

#### Issue pending migrations when starting Docker container

If you have pending migrations that **prevent the Docker container from starting** for example:

```
app | You have 2 pending migrations:
app |   20200603071312 ________
app |   20200603081325 ________
app | Run `rake db:migrate` to update your database then try again.
app exited with code 1
```

Then you can fix this by running the following command and then starting services again.

```
make db_migrate
```

#### Issue pending migrations with running the application

If after you start the application and you see the following in the terminal:

```
Migrations are pending. To resolve this issue, run: bin/rake db:migrate RAILS_ENV=development
```

Then you need to run the migration in a terminal session in the running docker container. Keep the services running and then run the following command:

```
make db_migrate
```

#### Issue during db migration

If you get a an error while running database migrations for example:

```
StandardError: An error has occurred, this and all later migrations canceled:
```

Then you can drop the database and restart the services like so:

```
make stop_all
make db_drop
make start_core
```

Note after doing this you may still need to run the database migrations. If you still have an error with the migration then check the migrations and ask the developer who committed them to help you!

#### Issue missing Gem dependency

Sometimes you might start the service and the container cannot start because it returns an error due to a missing Gem dependency, something like this:

```
app |  Could not find ________ in any of the sources
app |  Run `bundle install` to install missing gems.
app |  exited with code 7
```

Then, it means there is a Gem depenency missing. You should rebuild the image like this and then start the services again.

```
make build_app
```

#### Issue version discrepency with a Gem

Sometimes you might start the service and the container cannot start because it returns an error due to a version discrepency with a Gem, something like this:

```
app | The bundle currently has ______ locked at x.y.z.
app | Try running `bundle update ______`
app |
app | If you are updating multiple gems in your Gemfile at once,
app | try passing them all to `bundle update`
app | Run `bundle install` to install missing gems.
app | exited with code 7
```

Then, it means there is a Gem version discrepency. You should rebuild the image like this and then start the services again.

```
make build_app
```

#### Issue missing JavaScript dependency

Then, it means there is a JavaScript package depenency missing. You should rebuild the image like this and then start the services again.

In your terminal you might see something like this or someother error representing a missing JavaScript module.

Usually what's happened is the yarn.lock file contains a reference to a module that is not currently in your `node_modules` folder:

```
Module not found: _____
Error: Can't resolve _____
```

To fix this issue, run the following commands:

```
make yarn_install
```

#### Issue with Mongo DB

If you find Mongo DB is in a state that is not consistent or causing some unexpected errors that appear to be related to the MongoDB collections, you can completely remove the Mongo DB data files and start again. Note that in follownig this process all your local MongoDB data will be erased so take a backup if you need to first.

```
docker-compose stop mongo
rm -rf tmp/mongo
make start_mongo
```

Using the OSCaR Web Application try saving a record to the database. For example, [Create a New Client](http://dev.start.localhost:3000/clients/new?country=cambodia&locale=en). Once this is finished you should be able to see the data saved in MongoDB via the console:

```
make mongo_console
...
> db
oscar_history_development
> show collections
client_histories
> db.client_histories.find()[0]
{
  "_id" : ObjectId("5ef2fec9c245050001d8244f"),
  "tenant" : "dev",
  "object" : {
    "id" : 11,
    "code" : "",
    "given_name" : "Darren",
    "family_name" : "Jensen",
    "gender" : "male",
    "date_of_birth" : null,

ETC.....
```

### Issue starting the app container

If you have an issue starting the container, perhaps because Rails does not start due to a dependency issue or something else and you just need to get into the container without starting rails or any services or you don't want to rebuild the entire image so you can debug this issue quickly, then run the following command (make sure you are in the project directory first as it mounts the current directort into this container):

```
make run_image_bash
```

### Gazetteer Data Import (OPTIONAL)

Since importing the Gazetteer data takes sometime and the spreadsheet files are fairly large this as been left as an option if you need it.

Firstly, download the [Cambodia Gazetteer Spreadsheets](https://drive.google.com/drive/folders/1ff0GbLahKc0roUB71yjFNDwLY328AeKE), extract the zip file into the following local project directory `vendor/data/villages/xlsx`.

Now, inside the app container, run the following rake task where 'dev' is the name of the tenant / schema you want to import the Gazetteer Data into.

```
rake communes_and_villages:import['dev']
```

### Docker Commands

Start bash session in the 'app' service container. Once you have a session, you can use it like you would normally use your local terminal, running `rake` tasks, starting the `rails c` console etc, etc

To start a bash terminal that is running inside the Docker container run:

```
make bash_console
```

```
make rails_console
```

There is also a make command to drop the database

```
make db_drop
```

Check the local [Makefile](./Makefile) for a complete list of available commands.

### pgAdmin

The Docker Compose file contains a pgAdmin service. After `docker-compose up` spins up all the services, its possible to connect to pgAdmin at [http://localhost:5050/](http://localhost:5050/). The pgAdmin username and password are in the `pgadmin` services definition in [docker-compose.yml](./docker-compose.yml). To connect to the oscar database, simply expand the OSCaR Server Group in the top left and click on the database. You will be asked to enter the db password (123456789).

Note, if you only started the 'core' services and you want to fire up pgAdmin service too, then simply run the following command at your local terminal (note this will also startup the `db` service (Postgres) if it is not running):

```
docker-compose up pgadmin
```

### Mongo Express

The Docker Compose file contains a [Mongo Express](https://github.com/mongo-express/mongo-express) service. After `docker-compose up` spins up all the services, its possible to connect to Mongo Express at [http://localhost:8081/](http://localhost:8081/). There is no username or password required.

Note, if you only started the 'core' services and you want to fire up Mongo Express service too, then simply run the following command at your local terminal (note this will also startup the `mongo` service (MongoDB) if it is not running):

```
docker-compose up mongo-express
```

### Code Linting

#### Sorbe

`bundle exec rake rails_rbi:model`
For more instruction please read: [sorbet-rails](https://github.com/chanzuckerberg/sorbet-rails)

#### Rubocop

`rubocop app/models/bar.rb`

#### Text Editors Rubocop ruby linters

So if you use Vcode, you should use the plugin [ruby-rubocop](https://marketplace.visualstudio.com/items?itemName=misogi.ruby-rubocop) and if you use sublime you should use [SublimeLinterRubocop](https://packagecontrol.io/packages/SublimeLinter-rubocop) and this bellow is the sublime config

```
// SublimeLinter Settings - User
{
  "debug": true,
  "linters": {
    "rubocop": {
      "executable": "/Users/your_user_name/.rbenv/shims/rubocop",
      "excludes": ["**/*.js.erb"],
      "args": ["--config", ".rubocop.yml"]
    }
  },
  "paths": {
    "osx": [
      "~/.rbenv/shims"
    ]
  }
}
```

Noted: /Users/your_user_name/.rbenv/shims/rubocop you might use RVM so you can find rubocop by running `which rubocop` and use that path and see the path if you use `Linux` change key to Linux and use `rvm` path instead

## Pre-Commit and Pre-Push Hooks

Using bash scripts to check commit and ran test before pushing to GitHub

`chmod +x scripts/*.bash`
And then run
`./scripts/install-hooks.bash`
