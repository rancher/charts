CHARTS_BUILD_SCRIPT_VERSION := fdf0565

pull-scripts:
	./scripts/pull-scripts

TARGETS := prepare patch charts clean sync validate rebase docs

$(TARGETS):
	@ls ./bin/charts-build-scripts 1>/dev/null 2>/dev/null || ./scripts/pull-scripts
	./bin/charts-build-scripts $@

.PHONY: $(TARGETS)