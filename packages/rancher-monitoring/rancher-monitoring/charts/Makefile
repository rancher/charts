export PATH := $(CURDIR)/bin:$(PATH)

TARGETS := $(shell ls scripts|grep -ve "^util-")

# Default behavior for targets
$(TARGETS):
	./scripts/$@

.DEFAULT_GOAL := default

# Charts Build Scripts
pull-scripts:
	@command -v dep-fetch >/dev/null 2>&1 || { echo "WARNING: dep-fetch not found, skipping pull-scripts (expected in ci-image/charts environments)"; exit 0; }; dep-fetch sync

remove:
	./scripts/remove-asset

rebase:
	./scripts/charts-build-scripts/rebase

dev-prepare: pull-scripts
	@charts-build-scripts prepare --soft-errors --debug

dev-prepare-cached: pull-scripts
	@charts-build-scripts prepare --soft-errors --debug --useCache

prepare-cached: pull-scripts
	@charts-build-scripts prepare --useCache

patch-cached: pull-scripts
	@charts-build-scripts patch --useCache

charts-cached: pull-scripts
	@charts-build-scripts charts --useCache

CHARTS_BUILD_SCRIPTS_TARGETS := prepare patch clean clean-cache charts list index unzip zip standardize template

$(CHARTS_BUILD_SCRIPTS_TARGETS): pull-scripts
	@charts-build-scripts $@

.PHONY: $(TARGETS) $(CHARTS_BUILD_SCRIPTS_TARGETS) list

list-make:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
# IMPORTANT: The line above must be indented by (at least one)
#            *actual TAB character* - *spaces* do *not* work.
