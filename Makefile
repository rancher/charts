.DEFAULT_GOAL := help

help:
	@echo "Automation-Core Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  release-versions-template - Generate templates/release-versions.yaml from config/chart-families.yaml"
	@echo "  release-done                       - Mark release/*.yaml versions as Released when present in release-v* index.yaml"
	@echo "  yaml-standard-enforce              - Normalize release/*.yaml formatting with yq"
	@echo "  propagate                          - Propagate automation-core infrastructure to active branches"
	@echo "  reset-propagate                    - Clean up propagate containers, image, and temp files"
	@echo "  help                               - Show this help message"

release-versions-template:
	./release/scripts/generate-release-versions-template

release-done:
	./release/scripts/release-done

yaml-standard-enforce:
	./release/scripts/yaml-standard-enforce

propagate:
	./scripts/automation/propagate

reset-propagate:
	./scripts/automation/reset-propagate

.PHONY: help release-versions-template release-done yaml-standard-enforce propagate reset-propagate
