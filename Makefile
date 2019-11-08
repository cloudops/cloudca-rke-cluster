# Project variables
NAME        := cloudca-rke-cluster
DESCRIPTION := Terraform config to create RKE cluster on cloud.ca
AUTHO       := Khosrow Moossavi (@khos2ow)
URL         := https://github.com/khos2ow/cloudca-rke-cluster
LICENSE     := MIT

.PHONY: default
default: help

.PHONY: clean
clean: ## Clean cached and plan files
	@ $(MAKE) --no-print-directory log-$@
	rm -rf .terraform/ terraform.tfplan terraform.tfstate.backup terraform.tfstate generated/

.PHONY: init
init: ## Init configs
	@ $(MAKE) --no-print-directory log-$@
	@ terraform init

.PHONY: validate
validate: ## Validate configs
	@ $(MAKE) --no-print-directory log-$@
	@ terraform validate && echo "OK"

.PHONY: fmt
fmt: ## Format configs
	@ $(MAKE) --no-print-directory log-$@
	@ terraform fmt && echo "OK"

.PHONY: checkfmt
checkfmt: ## Check configs format
	@ $(MAKE) --no-print-directory log-$@
	@ terraform fmt -check=true && echo "OK"

.PHONY: document
document: START_TOKEN := <!-- terraform-docs starts -->
document: END_TOKEN   := <!-- terraform-docs ends -->
document: ## Generate document in README
	@ $(MAKE) --no-print-directory log-$@
	@ if [ "`grep "terraform-docs starts" README.md | wc -l`" = 0 ]; then															\
		echo "${START_TOKEN}\n" >> README.md ;																		\
		terraform-docs --with-aggregate-type-defaults markdown document ./ >> README.md ;												\
		echo "${END_TOKEN}" >> README.md ;																		\
	else																							\
		terraform-docs --with-aggregate-type-defaults markdown document ./ > "./tmp_doc" ;												\
		perl -i -ne 'if (/${START_TOKEN}/../${END_TOKEN}/) { print $$_ if /${START_TOKEN}/; print "\nI_WANT_TO_BE_REPLACED\n$$_" if /${END_TOKEN}/;} else { print $$_ }' README.md ;	\
		perl -i -e 'open(F, "'"./tmp_doc"'"); $$f = join "", <F>; while(<>){if (/I_WANT_TO_BE_REPLACED/) {print $$f} else {print $$_};}' README.md ;					\
		rm -f "./tmp_doc" ;																				\
	fi ;																							\
	echo "OK"

.PHONY: plan
plan: TFPLAN ?= terraform.tfplan
plan: ## Generate an execution plan
	@ $(MAKE) --no-print-directory log-$@
	@ terraform plan -out=${TFPLAN}

.PHONY: apply
apply: TFPLAN ?= terraform.tfplan
apply: ## Apply changes
	@ $(MAKE) --no-print-directory log-$@
	@ terraform apply -input=false ${TFPLAN}

.PHONY: output
output: ## Generate output
	@ $(MAKE) --no-print-directory log-$@
	@ terraform output

.PHONY: refresh
refresh: ## Refresh state
	@ $(MAKE) --no-print-directory log-$@
	@ terraform refresh

####################################
## Self-Documenting Makefile Help ##
####################################
.PHONY: help
help:
	@ grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

log-%:
	@ grep -h -E '^$*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m==> %s\033[0m\n", $$2}'
