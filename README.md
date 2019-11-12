[ ![Codeship Status for rotati/oscar-web](https://app.codeship.com/projects/0c400840-e69a-0134-b09a-26edd27a570b/status?branch=master)](https://app.codeship.com/projects/206873)

# OSCaR

Open Source Case-management and Record-keeping.

### Requirements

* Docker Desktop (latest stable version)

### Getting Started

Given that we are using Docker, simply run:

```
docker-compose up
```

Once the containers have fired up open a web browser and navigate to `http://localhost:3000` to view the app.

### Docker Commands

Start bash session in the 'app' service container. Once you have a session, you can use it like you would normally use your lcoal terminal, running `rake` tasks, starting the `rails c` console etc, etc

```
make bash_app
```

There is also a make command to drop the database

```
make db_drop
```

Check the local [Makefile](./Makefile) for a complete list of available commands.

### RSpec

Requirement

  Phanthomjs

  Pleas Install Phanthomjs as it is the dependency of poltegiest in order to run js true spec

  Install Phanthomjs for OSX

  ```
    npm install -g phantomjs
  ```

  Install Phanthomjs for Ubuntu

  ```
    sudo apt-get install phantomjs
  ```

The project is well tested using RSpec and Capybara.

To run all specs, testing environment must be setup.
Navigate to project root directory and run the following commands:

```
  bundle install RAILS_ENV=test

  rake db:create RAILS_ENV=test

  rake db:migrate RAILS_ENV=test

  rake db:seed RAILS_ENV=test  # to load some basic data
```

To run all specs, in your project root directory in terminal, run this command:

```
  rspec
```

### Issue Reporting

If you experience with bugs or need further improvement, please create a new issue in the repo issue list.

### Contributing to OSCaR

Pull requests are very welcome. Before submitting a pull request, please make sure that your changes are well tested. Pull requests without tests will not be accepted.

### Authors

OSCaR is developed in partnership by [Rotati Consulting](http://www.rotati.com) and [CIF](http://www.childreninfamilies.org)

### License

OSCaR Web Application is released under [AGPL](http://www.gnu.org/licenses/agpl-3.0-standalone.html)
