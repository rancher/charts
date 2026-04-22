.DEFAULT_GOAL := help

help:
	@echo "Automation-Core Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  update-dependencies  - Check SUSE package versions/checksums and update dependencies action"
	@echo "  test-dependencies    - Test dependencies action locally using act (requires Docker)"
	@echo "  propagate            - Propagate automation-core infrastructure to active branches"
	@echo "  reset-propagate      - Clean up propagate containers, image, and temp files"
	@echo "  help                 - Show this help message"

update-dependencies:
	./scripts/automation/update-dependencies

test-dependencies:
	act -j test-dependencies --container-architecture linux/amd64

propagate:
	./scripts/automation/propagate

reset-propagate:
	./scripts/automation/reset-propagate

.PHONY: help update-dependencies test-dependencies propagate reset-propagate
