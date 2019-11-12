# Some useful commands that can be run using make
bash_app:
	docker-compose run --entrypoint bash app

db_drop:
	docker-compose run --entrypoint "rake db:drop" app