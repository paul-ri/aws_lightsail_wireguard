include tools/base_makefile.mk

##@ Cloud deployment

deploy: ## Deploy resources
	./deploy.sh
.PHONY: deploy

destroy: ## Destroy resources
	./destroy.sh
.PHONY: destroy

##@ Configs deployment

push-config-to-chromebook: ## Push config to chromebook
	scp wg_client_configs/wg0-chromebook.conf chromebook-via-dlink:
	ssh -t -via-dlink sudo mv /home/paul/wg0-chromebook.conf /etc/wireguard/wg0.conf
.PHONY: push-config-to-chromebook

push-config-to-mdu-laptop: ## Push config to mdu-laptop
	scp wg_client_configs/wg0-mdulaptop.conf mdu-laptop:
	ssh -t mdu-laptop sudo mv /home/paul/wg0-mdulaptop.conf /etc/wireguard/wg0.conf
.PHONY: push-config-to-mdu-laptop