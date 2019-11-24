# Just start the Rails app and Postgres DB
start_core:
	docker-compose up --no-deps app db

# Start up all services (beware if you running this on a computer with less than 16GB RAM!)
start_all:
	docker-compose up

# Some useful commands that can be run using make
app_shell:
	docker-compose run --entrypoint bash app

# Connect to a mongo shell session (mongo service must be started first)
mongo_shell:
	docker exec -it mongo mongo -u oscar -p 123456789 oscar_history_development

# Connect to a postgres shell session (mongo service must be started first)
db_shell:
	docker exec -it db psql -U oscar oscar_development

# Drop the postgres database (if error retry as db service needs to start first)
db_drop:
	docker-compose run --entrypoint "rake db:drop" app

# Create test database (run `make start_core` at least first!)
db_create_test:
	docker-compose run --no-deps -e RAILS_ENV=test --entrypoint "rake db:drop" app
	docker-compose run --no-deps -e RAILS_ENV=test --entrypoint "rake db:create" app
	docker-compose run --no-deps -e RAILS_ENV=test --entrypoint "rake db:schema:load" app