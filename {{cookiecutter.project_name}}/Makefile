.PHONY: help pre-commit

ifneq ($(CI), true)
-include .env
endif

# Detecting OS
UNAME_S := $(shell uname -s)
ifeq ($(OS),Windows_NT)
    PYTHON := python
    BASH := bash -c
    TF_OS_ARCH := windows_amd64
    TF_EXT := .exe
    TG_SUFFIX := _windows_amd64.exe
    ARCHIVE_CMD = cd .terraform-bin && tar -xf terraform.zip && rm terraform.zip
    PIP_FLAGS :=
else ifeq ($(UNAME_S),Linux)
    PYTHON := python3
    BASH := /bin/bash -c
    TF_OS_ARCH := linux_amd64
    TF_EXT :=
    TG_SUFFIX := _linux_amd64
    ARCHIVE_CMD = cd .terraform-bin && unzip -o terraform.zip && rm terraform.zip
    PIP_FLAGS := --break-system-packages
endif

ENVIRONMENT ?= dev
TF_VERSION := $(shell cat .tf_version)
TG_VERSION := $(shell cat .tg_version)
TF_BIN = $(CURDIR)/.terraform-bin/terraform$(TF_EXT)
TG_BIN = $(CURDIR)/.terragrunt-bin/terragrunt$(TF_EXT)
.DEFAULT_GOAL := help

TF_DIR = tf/{{cookiecutter.project_name}}/environments/$(ENVIRONMENT)
ANSIBLE_DIR = tf/{{cookiecutter.project_name}}/ansible
PLAYBOOK ?= nginx
export TG_TF_PATH := $(TF_BIN)

.EXPORT_ALL_VARIABLES:

##pre-commit Instalar precommit
pre-commit:
	@$(PYTHON) -m pip install pre-commit -q $(PIP_FLAGS)
	@$(PYTHON) -m pre_commit install --hook-type pre-commit --hook-type pre-push
	@$(PYTHON) -m pre_commit autoupdate

##lint pre-commit lint
lint: fmt
	@$(PYTHON) -m pre_commit run --all-files

##check-tf-version   descargar terraform de manera local
check-tf-version:
	@mkdir -p .terraform-bin
	@curl -sL https://releases.hashicorp.com/terraform/$(TF_VERSION)/terraform_$(TF_VERSION)_$(TF_OS_ARCH).zip -o .terraform-bin/terraform.zip
	@$(ARCHIVE_CMD)
	@$(TF_BIN) --version

##check-tg-version   descargar terragrunt de manera local
check-tg-version:
	@mkdir -p .terragrunt-bin
	@curl -sL https://github.com/gruntwork-io/terragrunt/releases/download/v$(TG_VERSION)/terragrunt$(TG_SUFFIX) -o $(TG_BIN)
ifeq ($(UNAME_S),Linux)
	@chmod +x $(TG_BIN)
endif
	@$(TG_BIN) --version

##install Instala ambas versiones de terraform y terragrunt
install: check-tf-version check-tg-version

## init:			terraform init
init:
	cd $(TF_DIR) && "$(TG_BIN)" run --all init

## init-upgrade:		terraform init -upgrade
init-upgrade:
	cd $(TF_DIR) && "$(TF_BIN)" init -upgrade

## init-reconfigure:		terraform init -reconfigure
init-reconfigure:
	cd $(TF_DIR)/$(MODULE) && "$(TG_BIN)" init -reconfigure

## fmt:			terraform fmt -recursive
fmt:
	"$(TF_BIN)" fmt -recursive

## ci-fmt:			terraform fmt -recursive -check -diff -write=false
ci-fmt:
	"$(TF_BIN)" fmt -recursive -check -diff -write=false

## plan:			terraform plan
plan:
	cd $(TF_DIR)/$(MODULE) && "$(TG_BIN)" plan

state:
	cd $(TF_DIR)/$(MODULE) && "$(TG_BIN)" state list

## apply:			terraform apply
apply:
	cd $(TF_DIR)/$(MODULE) && "$(TG_BIN)" apply

## destroy:		terraform destroy
destroy:
	cd $(TF_DIR)/$(MODULE) && "$(TG_BIN)" destroy

destroy-all:
	cd $(TF_DIR) && "$(TG_BIN)" run -all destroy

force-unlock:
	cd $(TF_DIR)/$(MODULE) && "$(TG_BIN)" force-unlock $(ID)

outputs:
	cd $(TF_DIR) && "$(TG_BIN)" run --all output

outputs-private-keys:
	mkdir -p $(TF_DIR)/compute/.pems
	for dir in $(TF_DIR)/compute $(TF_DIR)/compute/mx-central-1; do \
		(cd $$dir && "$(TG_BIN)" output -json private_keys 2>/dev/null | $(PYTHON) -c \
		"import json,sys,os; d=json.load(sys.stdin); \
		[open(f'$(CURDIR)/$(TF_DIR)/compute/.pems/{k}.pem','w').write(v) or os.chmod(f'$(CURDIR)/$(TF_DIR)/compute/.pems/{k}.pem',0o400) for k,v in d.items()]") || true; \
	done

clean-cache:
	rm -rf $(TF_DIR)/$(MODULE)/.terragrunt-cache
	rm -f $(TF_DIR)/$(MODULE)/.terraform.lock.hcl

## validate:		terraform validate across all environments
validate:
	sh ./scripts/tf-validate.sh

## tf-shell:		opens a shell inside tf dir with env loaded
tf-shell:
	cd $(TF_DIR) && $$SHELL

## env-init:		crea la carpeta de ambiente
env-init:
	@mkdir -p .envs/.$(ENVIRONMENT)
	@awk '/- name:/{name=$$3} /example:/{print name"="$$2}' envvars.yml > .envs/.$(ENVIRONMENT)/.aws

## env-merge:		crea el archivo .env a partir de los .envs
env-merge:
	@$(PYTHON) merge_local_dotenvs_in_dotenv.py $(ENVIRONMENT)

##ansible-install:	instala ansible
ansible-install:
	$(PYTHON) -m pip install ansible $(PIP_FLAGS)

##ansible-inventory:	genera el inventario de Ansible agrupado por tag AnsibleGroup
ansible-inventory:
	@mkdir -p $(ANSIBLE_DIR)/inventory
	@> $(ANSIBLE_DIR)/inventory/hosts.ini
	@for dir in $(TF_DIR)/compute $(TF_DIR)/compute/mx-central-1; do \
		(cd $$dir && "$(TG_BIN)" output -json instances 2>/dev/null | \
		$(PYTHON) $(CURDIR)/$(ANSIBLE_DIR)/generate_inventory.py \
		--pems-dir $(CURDIR)/$(TF_DIR)/compute/.pems \
		--output $(CURDIR)/$(ANSIBLE_DIR)/inventory/hosts.ini) || true; \
	done
	@echo "Inventario generado en $(ANSIBLE_DIR)/inventory/hosts.ini"

##ansible-run:		corre un playbook de Ansible contra el grupo correspondiente
ansible-run:
	ansible-playbook \
		-i $(ANSIBLE_DIR)/inventory/hosts.ini \
		$(ANSIBLE_DIR)/playbooks/$(PLAYBOOK).yml

## check-env:
check-env:
ifneq ($(CI), true)
	@grep -v '^#' .env | grep -v '^$$'
else
	@echo "CI mode: .env no disponible"
endif

## help:			show this help
help:
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)