# Forces a rebild of the app image for example to update dependencies in the image
build_app:
	docker-compose build app

# Just start the Rails app, webpack dev server and Postgres DB
start_core:
	docker-compose up --no-deps app db webpack

start_mongo:
	docker-compose up mongo

# Start up all services (beware if you running this on a computer with less than 16GB RAM!)
start_all:
	docker-compose up

stop_all:
	docker-compose down

# Starts up a bash terminal in the app container
bash_console:
	docker exec -it app bash

bash_console:
	docker exec -it app bash

# Starts up a rails console in the app container
rails_console:
	docker exec -it app rails c

# Use this to attach to the running rails app terminal for use with Pry for example
rails_attach:
	docker attach $(shell docker-compose ps -q app)

# Starts up a guard console in the app container
guard_console:
	docker exec -it app guard

# Starts up a mongo console in the mongo container
mongo_console:
	docker exec -it mongo mongo -u oscar -p 123456789 oscar_history_development

# Starts up a psql console in the db container
psql_console:
	docker exec -it db psql -U oscar oscar_development

# Drop the postgres database (if error retry as db service needs to start first)
db_drop:
	docker-compose run --entrypoint "rake db:drop" app db

# Run migrations against the database
db_migrate:
	docker-compose run --entrypoint "rake db:migrate" app db

yarn_install:
	docker exec -it app yarn install --check-files

# Create test database (run `make start_core` at least first!)
db_create_test:
	docker-compose run --no-deps -e RAILS_ENV=test --entrypoint "rake db:drop" app
	docker-compose run --no-deps -e RAILS_ENV=test --entrypoint "rake db:create" app
	docker-compose run --no-deps -e RAILS_ENV=test --entrypoint "rake db:schema:load" app
