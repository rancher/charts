pull-scripts:
	./scripts/pull-scripts

remove:
	./scripts/remove-asset

forward-port:
	./scripts/forward-port

check-release-yaml:
	./scripts/check-release-yaml

TARGETS := prepare patch clean clean-cache charts list index unzip zip standardize validate template regsync check-images check-rc icon

$(TARGETS):
	@./scripts/pull-scripts
	@./bin/charts-build-scripts $@

.PHONY: $(TARGETS)