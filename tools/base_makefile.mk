# DESCRIPTION
# 	Helpers and recipes to deploy AWS CloudFormation templates.
#
# USAGE
#	- These makefiles must be included before the current file:
#		* ./base_makefile.mk
#	- Look at USAGE_STACK_DEPLOYMENT or type in 'make help'

define USAGE
Usage:
	- Call a specific rule
		make <rule_name>
	- Calls a makerule with specific arguments
		make <rule_name> STACK_NAME=banana ENVIRONMENT=test
		# Can be set as environment variables too
		STACK_NAME=banana ENVIRONMENT=test make <rule_name>

Generic arguments:
	DEBUG                          Depending on the environment, will be set to "y" or unset. Current: $(DEBUG)
	USE_IAM_ROLE                   If set, AWS_PROFILE is not inferred from ENVIRONMENT and AWS commands will use the default AWS profile.
endef
export USAGE

#
# Environment
#
DEBUG ?= n

#
# Public helpers
#
# Current commit SHA value
COMMIT_HASH = $(shell git rev-parse HEAD | cut -c1-7)
BUILD_TAG = $(shell git rev-parse HEAD | cut -c1-7)
BRANCH_NAME ?= $(shell git branch --show-current)

# Detect if we are in a continuous integration environment or not. Note: This is potentially not robust but works on Jenkins
ifndef TERM
IS_CI := y
# Allows tput to know the type of terminal. Jenkins does not set the variable, causing warnings
export TERM = dumb
endif

define echo_bold
echo $$(tput bold)### $(1)$$(tput sgr0)
endef
define echo_red_bold
echo $$(tput bold;tput setaf 1)### $(1)$$(tput sgr0)
endef
# Determines if a variable is defined or not
# Usage: $(if $(call defined,VARIABLE), echo defined, echo undefined)
defined = $(strip $(filter-out undefined,$(flavor $1)))

# Displays a bold prompt waiting for user input. Any answer other than ["Y", "y", "yes"] will exit the program
# 	- argument 1: The text to display
define yes_no_prompt =
	@read -e -p "$$(tput bold)$(1)$$(tput sgr0)" confirmation;\
	if [[ $$confirmation != "Y" && $$confirmation != "y" && $$confirmation != "yes"  ]]; then \
		echo "Exited by user";\
		exit 1;\
	fi
endef

# Log command output in file. Further commands will have their output be recorded in a file as well as being printed on screen.
# This means color will not be displayed as they programs will know they are in a non-interractive shell.
# use `unbuffer program [ args ]` to have colors back (but also the logs having the color codes)
# Usage:
# 		$(call log_output,stdout.log);\ # Watch out for spaces after the comma
#		unbuffer npm install
# - arg1: Log filename
define log_output
	exec 1> >(tee "$(1)") 2>&1
endef

# To be used as newline when calling $(error) or $(info) in make
# https://stackoverflow.com/a/17055840
define n


endef

#
# Private helpers & parameters
# ============================
#

# Do not set AWS_PROFILE if wanting to use an IAM role.
# Useful for Jenkins which already runs on EC2 which has its own IAM role.
ifndef USE_IAM_ROLE
export AWS_PROFILE ?= mdu-services
else
$(info AWS_PROFILE unset, using IAM role)
endif

# We always want to explicitly state this - for some reason some tools don't like to read ~/.aws/config
export AWS_SDK_LOAD_CONFIG=1

SHELL := bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
.SHELLFLAGS := -euo pipefail -c
# Referring to Make variables that don't exist will warn you
MAKEFLAGS += --warn-undefined-variables

TOOLS_DIRECTORY := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../tools
CFN_SCRIPTS_DIRECTORY := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))/../cfn-scripts
#
# Rules
# =====
#
.DEFAULT_GOAL := help

##@ Imported targets

# Borrowed from https://www.thapaliya.com/en/writings/well-documented-makefiles/
help: ## Display this help section
	@echo "$$USAGE"
	@echo -e "\nMake rules available:"
	@awk 'BEGIN {FS = ":.*##"; printf "\033[36m\033[0m"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help
