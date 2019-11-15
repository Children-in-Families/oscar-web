# Some useful commands that can be run using make
bash_app:
	docker-compose run --entrypoint bash app

# Connect to a shell session (mongo service must be started first)
mongo_shell:
	docker exec -it mongo mongo -u oscar -p 123456789 oscar_history_development

# Drop the postgres database (if error retry as db service needs to start first)
db_drop:
	docker-compose run --entrypoint "rake db:drop" app