[![Build Status](https://travis-ci.org/rotati/children-in-families-web.svg?branch=set-up-travis-spec)](https://travis-ci.org/rotati/children-in-families-web)

# Children in Families Child Care Managment Database Application

Family based care is quickly becoming the worldwide ideal in addressing the needs of orphans and vulnerable children.  As governments and NGOs continue to expand their services to these vulnerable populations, the need for proper and efficient monitoring and case management of children in Kinship and Foster Care will only grow.

In many countries, current paper based systems are inefficient and outdated. Existing database solutions are slow and are poorly designed resulting in data duplication and confusion.  An open source case management system such as Children in Families will remove startup barriers and enable NGOs and governments to implement quality family based care solutions.

### Installation Requirements

* Postgres (>= 9.3)
* Ruby (2.2.0)
* Rails (4.2.2)

### Getting Started

Given that you have all the requirements running on your local machine.

Clone the project to your local machine:

```
  git clone https://github.com/rotati/children_in_families.git
```

Navigate to the project directory and create `.env` in project root path, and copy all content in `.env.example` and replace all variable values to fit your local machine.

In the .env file you created, make sure to set ADMIN_EMAIL to your email and ADMIN_PASSWORD to a password that you will use to login.

Make sure you set all the variables in the .env file before you run the commands below!

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

The project is well tested using RSpec and Capybara.

To run all specs, testing environment must be setup.
Navigate to project root directory and run the following commands:

```
  rake db:create RAILS_ENV=test

  rake db:migrate RAILS_ENV=test
```

To run all specs, in your project root directory in terminal, run this command:

```
  rspec
```

### Issue Reporting

If you experience with bugs or need further improvement, please create a new issue in the repo issue list.

### Contributing to Children in Families

Pull requests are very welcome. Before submitting a pull request, please make sure that your changes are well tested. Pull requests without tests will not be accepted.

### Authors

Children in Families is developed in partnership by [Rotati Consulting](http://www.rotati.com) and [CIF](http://www.childreninfamilies.org)

### License

Children in Families is released under [AGPL](http://www.gnu.org/licenses/agpl-3.0-standalone.html)
