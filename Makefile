pull-scripts:
	./scripts/pull-scripts

remove:
	./scripts/remove-asset

forward-port:
	./scripts/forward-port

check-release-yaml:
	./scripts/check-release-yaml

validate:
	@./scripts/pull-scripts
	@./bin/charts-build-scripts validate $(if $(filter true,$(remote)),--remote) $(if $(filter true,$(local)),--local)

TARGETS := prepare patch clean clean-cache charts list index unzip zip standardize template regsync check-images check-rc enforce-lifecycle lifecycle-status

$(TARGETS):
	@./scripts/pull-scripts
	@./bin/charts-build-scripts $@

.PHONY: $(TARGETS)