.DEFAULT_GOAL := help

help:
	@echo "Automation-Core Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  release-versions-template - Generate templates/release-versions.yaml from config/chart-families.yaml"
	@echo "  propagate                          - Propagate automation-core infrastructure to active branches"
	@echo "  reset-propagate                    - Clean up propagate containers, image, and temp files"
	@echo "  help                               - Show this help message"

release-versions-template:
	./release/scripts/generate-release-versions-template

propagate:
	./scripts/automation/propagate

reset-propagate:
	./scripts/automation/reset-propagate

.PHONY: help release-versions-template propagate reset-propagate
