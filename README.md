[![Build Status](https://travis-ci.org/rotati/children-in-families-web.svg?branch=master)](https://travis-ci.org/rotati/children-in-families-web)

# Children in Families

Children in Families is a local Christian non-profit registered in the Kingdom of Cambodia.

### Requirements

* Postgres(>= 9.3)
* Ruby(2.2.0)
* Rails(4.2.2)

### Getting Start

Given that you got all the requirements running on your local machine.


Clone the project to your local machine:

```
  git clone https://github.com/rotati/children_in_families.git
```

Navigate to the project directory and create `.env` in project root path, and copy all content in `.env.example` and replace all variable values to fit your local machine.

Then run:

```
  bundle install

  rake db:create

  rake db:migrate

  rake db:seed  # to load some basic data
```

Once the steps are done, start the server by running:

```
  rails server
```

Open a web browser and navigate to `http://localhost:3000`, and there you go!

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

### Bugs Report and Improvements

If you experience with bugs or need further improvement, please create a new issue in the repo issue list.

### License

Children in Families is a free to use software and maintained by [Rotati Consulting](http://www.rotati.com/).
