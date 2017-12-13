default: build

build: 
	docker build -t pickmybruin/backend .	

run: 
	docker-compose down -rmi
	docker-compose up

restart:
	docker-compose restart web

shell:
	docker-compose exec backend /app/src/manage.py shell_plus

test:
	docker-compose exec backend /app/src/manage.py test --no-input --parallel $(args)

clean_db:
	docker-compose exec db psql -U postgres -c 'DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;'

init_db: clean_db 
	docker cp init_db.sql "$(shell docker-compose ps -q db)":/init_db.sql
	docker-compose exec db psql -U postgres -f /init_db.sql 
	docker-compose exec backend /app/src/manage.py migrate

backup_db:
	docker-compose exec db pg_dumpall -c -U postgres > badchess_dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql

install_package:
	docker-compose exec backend pip3 install $(pkg)
	docker-compose exec backend pip3 freeze | tail -n +1 > backend/requirements.txt
