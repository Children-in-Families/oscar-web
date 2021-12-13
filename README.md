# OSCaR - Open Source Case-management and Record-keeping

### Open Source Case-management and Record-keeping.

[![Build Status](https://travis-ci.com/DevZep/oscar-web.svg?branch=master)](https://travis-ci.com/DevZep/oscar-web)
[![Build Status](https://travis-ci.com/DevZep/oscar-web.svg?branch=stable)](https://travis-ci.com/DevZep/oscar-web)
[![Build Status](https://travis-ci.com/DevZep/oscar-web.svg?branch=staging)](https://travis-ci.com/DevZep/oscar-web)

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

| Master Branch                                                                                                       |                                                    Stable Branch                                                    |                                                    Staging Branch                                                    |
| ------------------------------------------------------------------------------------------------------------------- | :-----------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------: |
| [![Build Status](https://travis-ci.com/DevZep/oscar-web.svg?branch=master)](https://travis-ci.com/DevZep/oscar-web) | [![Build Status](https://travis-ci.com/DevZep/oscar-web.svg?branch=stable)](https://travis-ci.com/DevZep/oscar-web) | [![Build Status](https://travis-ci.com/DevZep/oscar-web.svg?branch=staging)](https://travis-ci.com/DevZep/oscar-web) |

### Open Source Case-management and Record-keeping.

OSCaR is an open source and free to use (under [AGPL](http://www.gnu.org/licenses/agpl-3.0-standalone.html)) software for case managment focusing on family care first policies of vulnerable children.

The service is available as a subscription via the [OSCaR Online Application](https://oscarhq.com) and can be run privately from this repository. For more information about using the hosted version via the online application please reach out to the support contacts there. If you are already using OSCaR and need support you can find the training manual available on the website as well as inline, contextual help thoughout the application.

### OSCaR Guides

We have three guides available depending on how you are wanting to use OSCaR, either via the hosted version, a private hosted version or locally to run tests or even contribute code to the project!

So with that, if you are:

- Looking for the **hosted version of OSCaR**, please visit out official [OSCaR Website](https://www.oscarhq.com)
- Want to **run a privately hosted vesion of OSCaR in the cloud** then visit the [private hosting guide](./guides/private-hosting)
- Want to **run a local vesion of OSCaR on your laptop** or home computer as a developer then visit [developer guide](./guides/developer)

### Issue Reporting

If you experience with bugs or need further improvement, please create a new issue under [Issues](https://github.com/Children-in-Families/oscar-web/issues).

### Contributing to OSCaR

Pull requests are very welcome. Before submitting a pull request, please make sure that your changes are well tested. Pull requests without tests will not be accepted.

#### Not sure what to work on?

Perhaps pick one of the [existing issues](https://github.com/Children-in-Families/oscar-web/issues) or submit an issue and then work on that. Alternatively, please feel free to reach out to one of the supporting authors either at DevZep or CIF as indicated below.

### Authors

OSCaR is developed by [CIF](http://www.childreninfamilies.org)

### License

OSCaR Web Application is released under [AGPL](http://www.gnu.org/licenses/agpl-3.0-standalone.html)
