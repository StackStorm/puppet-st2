THIS_FILE := $(lastword $(MAKEFILE_LIST))
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CI_REPO_PATH ?= $(ROOT_DIR)/ci
CI_REPO_BRANCH ?= master

.PHONY: all
all: .DEFAULT

.PHONY: clean
clean: clean-ci-repo clean-pyc clean-kitchen clean-puppet-librarian clean-bundler clean-pkg

# Clone the ci-repo into the ci/ directory
.PHONY: clone-ci-repo
clone-ci-repo:
	@echo
	@echo "==================== clone-ci-repo ===================="
	@echo
	@if [ ! -d "$(CI_REPO_PATH)" ]; then \
		git clone https://github.com/EncoreTechnologies/ci-puppet-python.git --depth 1 --single-branch --branch $(CI_REPO_BRANCH) $(CI_REPO_PATH); \
	else \
		cd $(CI_REPO_PATH); \
		git pull; \
	fi;

# Clean the ci-repo (calling `make clean` in that directory), then remove the
# ci-repo directory
.PHONY: clean-ci-repo
clean-ci-repo:
	@echo
	@echo "==================== clean-ci-repo ===================="
	@echo
	@if [ -d "$(CI_REPO_PATH)" ]; then \
		make -f $(ROOT_DIR)/ci/Makefile clean; \
	fi;
	rm -rf $(CI_REPO_PATH)

# Clean *.pyc files.
.PHONY: clean-pyc
clean-pyc:
	@echo
	@echo "==================== clean-pyc ===================="
	@echo
	find $(ROOT_DIR) -name 'ci' -prune -or -name '.git' -or -type f -name "*.pyc" -print | xargs -r rm

# Clean kitchen build files
.PHONY: clean-kitchen
clean-kitchen:
	@echo
	@echo "== clean-kitchen ======================================"
	@echo
	find "$(ROOT_DIR)" -type d -name '.kitchen' | xargs -r -t -n1 rm -rf

# Clean puppet-librarian build files
.PHONY: clean-puppet-librarian
clean-puppet-librarian:
	@echo
	@echo "== clean-puppet-librarian ============================="
	@echo
	find "$(ROOT_DIR)" -type d -name '.librarian' -or -type d -name '.tmp' | xargs -r -t -n1 rm -rf

# Clean bundler build files
.PHONY: clean-bundler
clean-bundler:
	@echo
	@echo "== clean-bundler ======================================"
	@echo
	rm -rf ${ROOT_DIR}/build/kitchen/.bundle
	rm -rf ${ROOT_DIR}/build/kitchen/vendor
	rm -rf ${ROOT_DIR}/.bundle
	rm -rf ${ROOT_DIR}/Gemfile.lock
	rm -rf ${ROOT_DIR}/vendor
	rm -rf /tmp/puppet-st2/build

# Clean packages
.PHONY: clean-pkg
clean-pkg:
	@echo
	@echo "== clean-pkg ======================================"
	@echo
	rm -rf ${ROOT_DIR}/pkg

# list all makefile targets
.PHONY: list
list:
	@if [ -d "$(CI_REPO_PATH)" ]; then \
		$(MAKE) --no-print-directory -f $(ROOT_DIR)/ci/Makefile list; \
	fi;
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort | uniq | xargs

# forward all make targets not found in this makefile to the ci makefile to do
# the actual work (by calling the invoke-ci-makefile target)
# http://stackoverflow.org/wiki/Last-Resort_Makefile_Targets
# Unfortunately the .DEFAULT target doesn't allow for dependencies
# so we have to manually specify all of the steps in this target.
.DEFAULT: 
	$(MAKE) clone-ci-repo
	@echo
	@echo "==================== invoke ci/Makefile (targets: $(MAKECMDGOALS)) ===================="
	@echo
	make -f $(ROOT_DIR)/ci/Makefile $(MAKECMDGOALS)
