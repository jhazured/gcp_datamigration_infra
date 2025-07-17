# Default environment variables
DOCKER_COMPOSE=docker-compose
COMPOSE_FILE=docker-compose.yml

# Services you have defined in the compose file
SERVICES=etl ansible terraform db

# Build all images
build: 
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build
	@echo "All images built"

# Bring up the services
up: 
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d
	@echo "All services are up and running"

# Bring up a specific service
up-service:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d $(SERVICE)
	@echo "$(SERVICE) is now running"

# Stop the services
down:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down
	@echo "All services are stopped"

# View logs of all services
logs:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f
	@echo "Displaying logs for all services"

# View logs for a specific service
logs-service:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f $(SERVICE)
	@echo "Displaying logs for $(SERVICE)"

# Remove all containers
clean:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans
	@echo "All containers and volumes removed"

# Remove all images
clean-images:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down --rmi all --volumes --remove-orphans
	@echo "All images, volumes, and orphaned containers removed"

# Execute a command in a running container
exec:
	$(DOCKER_COMPOSE) exec $(SERVICE) $(CMD)
	@echo "Executed command in $(SERVICE)"

# Build and bring up the services in one go
build-up: build up
	@echo "Images built and services brought up"

# Start a specific service and run a command
start-service-with-command:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d $(SERVICE)
	$(DOCKER_COMPOSE) exec $(SERVICE) $(CMD)
	@echo "$(SERVICE) is now running with command: $(CMD)"

# Run a custom command on a specific container
run-command:
	$(DOCKER_COMPOSE) exec $(SERVICE) $(CMD)

# Remove Docker volumes
remove-volumes:
	$(DOCKER_COMPOSE) down --volumes
	@echo "Docker volumes removed"

# Build the Docker images without bringing up the services
build-no-up:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build --no-cache
	@echo "Images built without cache"


# Environment management
load-env:
	@if [ -f env/.env.$(ENV) ]; then \
		export $$(cat env/.env.$(ENV) | xargs); \
	else \
		echo "Environment file env/.env.$(ENV) not found"; \
		exit 1; \
	fi

# Terraform operations
tf-init:
	cd terraform/envs/$(ENV) && terraform init

tf-plan:
	cd terraform/envs/$(ENV) && terraform plan -var-file=terraform.tfvars

tf-apply:
	cd terraform/envs/$(ENV) && terraform apply -var-file=terraform.tfvars

# Ansible operations
ansible-check:
	cd ansible && ansible-playbook -i inventory/localhost.yml playbook/setup_gcp_resources.yml --check

ansible-run:
	cd ansible && ansible-playbook -i inventory/localhost.yml playbook/setup_gcp_resources.yml
