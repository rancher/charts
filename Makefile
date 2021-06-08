pull-scripts:
	./scripts/pull-scripts

TARGETS := prepare patch charts clean validate template

$(TARGETS):
	@./scripts/pull-scripts
	@./bin/charts-build-scripts $@

.PHONY: $(TARGETS)