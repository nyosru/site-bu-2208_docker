
dev:
	@echo "Development environment started"
	cp docker-compose.local.yml docker-compose.yml
	docker-compose down
	docker-compose up -d --remove-orphans

create_web_laravel:

	@if ! docker network ls --format '{{.Name}}' | grep -w laravel > /dev/null; then \
		echo "Creating Docker network laravel"; \
		docker network create laravel; \
	else \
		echo "Docker network laravel already exists"; \
	fi


#remove-laravel-network:
#	docker network rm laravel || echo "Network laravel_network does not exist"


prod:
	@echo "- - -"
	@echo "- - -"
	@echo "+++ prod environment started"
	make create_web_laravel
#	@echo "- - -"
#	@echo "+++2 prod environment started"
#	cp caddy/prod.Caddyfile caddy/Caddyfile
	cp docker-compose.prod.yml docker-compose.yml
	docker compose down --rmi all -v
	docker compose up -d --build
	# make caddy_refresh_cfd_prod
	@echo "- - -"
	@echo "чистим кещ докера"
	make clear_docker_cache


clear_docker_cache:
	docker builder prune -f

