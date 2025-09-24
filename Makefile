# Makefile for ansible-k8s-setup

.PHONY: help install-deps check-inventory deploy clean test

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install-deps: ## Install Ansible dependencies
	ansible-galaxy collection install -r requirements.yml

check-inventory: ## Check inventory configuration
	ansible-inventory -i inventory/hosts.yml --list

check-connectivity: ## Check SSH connectivity to all nodes
	ansible all -i inventory/hosts.yml -m ping

prepare-nodes: ## Prepare all nodes for Kubernetes installation
	ansible-playbook -i inventory/hosts.yml playbooks/01-prepare-nodes.yml

install-containerd: ## Install containerd on all nodes
	ansible-playbook -i inventory/hosts.yml playbooks/02-install-containerd.yml

install-k8s: ## Install Kubernetes components on all nodes
	ansible-playbook -i inventory/hosts.yml playbooks/03-install-k8s.yml

install-helm: ## Install Helm on master node
	ansible-playbook -i inventory/hosts.yml playbooks/07-install-helm.yml

init-master: ## Initialize Kubernetes master node
	ansible-playbook -i inventory/hosts.yml playbooks/04-init-master.yml

join-workers: ## Join worker nodes to cluster
	ansible-playbook -i inventory/hosts.yml playbooks/05-join-workers.yml

install-ingress: ## Install Nginx Ingress Controller
	ansible-playbook -i inventory/hosts.yml playbooks/06-install-nginx-ingress.yml

deploy: ## Deploy complete Kubernetes cluster with Nginx Ingress
	ansible-playbook -i inventory/hosts.yml site.yml

deploy-quick: ## Quick deployment (skip some checks)
	ansible-playbook -i inventory/hosts.yml site.yml --skip-tags slow

test-cluster: ## Test cluster functionality
	ansible-playbook -i inventory/hosts.yml playbooks/test-cluster.yml

clean: ## Clean up cluster (WARNING: This will destroy the cluster)
	ansible-playbook -i inventory/hosts.yml playbooks/cleanup.yml

lint: ## Run Ansible linting
	ansible-lint playbooks/*.yml

validate: ## Validate playbooks syntax
	ansible-playbook --syntax-check -i inventory/hosts.yml site.yml
	ansible-playbook --syntax-check -i inventory/hosts.yml playbooks/*.yml
