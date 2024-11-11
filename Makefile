help:
	./bin/charts-build-scripts --help

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

chart-bump:
	@if [ -z "$(package)" ] || [ -z "$(branch)" ]; then \
		echo "Error: package and branch arguments are required."; \
		exit 1; \
	fi
	@./scripts/pull-scripts
	@./bin/charts-build-scripts chart-bump --package="$(package)" --branch="$(branch)"

TARGETS := prepare patch clean clean-cache charts list index unzip zip standardize template regsync check-images check-rc enforce-lifecycle lifecycle-status auto-forward-port

$(TARGETS):
	@./scripts/pull-scripts
	@./bin/charts-build-scripts $@

.PHONY: $(TARGETS)