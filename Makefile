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

prepare-cached: pull-scripts
	@./bin/charts-build-scripts prepare --useCache

patch-cached: pull-scripts
	@./bin/charts-build-scripts patch --useCache

charts-cached: pull-scripts
	@./bin/charts-build-scripts charts --useCache

validate:
	@./scripts/pull-scripts
	@./bin/charts-build-scripts validate $(if $(filter true,$(remote)),--remote) $(if $(filter true,$(local)),--local)

chart-bump:
	@if [ -z "$(package)" ] || [ -z "$(branch)" ] || [ -z "$(override)" ]; then \
		echo "Error: package, branch and override arguments are required."; \
		exit 1; \
	fi
	@./scripts/pull-scripts
	@./bin/charts-build-scripts chart-bump --package="$(package)" --branch="$(branch)" --override="$(override)" $(if $(multirc),--multirc="$(multirc)")

TARGETS := prepare patch clean clean-cache charts list index unzip zip standardize template regsync check-images check-rc enforce-lifecycle lifecycle-status auto-forward-port icon

$(TARGETS):
	@./scripts/pull-scripts
	@./bin/charts-build-scripts $@

.PHONY: $(TARGETS)
