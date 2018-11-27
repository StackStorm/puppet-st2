THIS_FILE := $(lastword $(MAKEFILE_LIST))
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: clean
clean: clean-kitchen clean-puppet-librarian clean-bundler clean-pkg

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
