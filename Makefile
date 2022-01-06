pull-scripts:
	./scripts/pull-scripts

remove:
	./scripts/remove-asset

TARGETS := prepare patch clean clean-cache charts list index unzip zip standardize validate template

$(TARGETS):
	@./scripts/pull-scripts
	@./bin/charts-build-scripts $@

.PHONY: $(TARGETS)