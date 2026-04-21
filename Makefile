.DEFAULT_GOAL := help

help:
	@echo "Automation-Core Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  update-dependencies  - Check SUSE package versions/checksums and update dependencies action"
	@echo "  test-dependencies    - Test dependencies action locally using act (requires Docker)"
	@echo "  help                 - Show this help message"

update-dependencies:
	./scripts/update-dependencies

test-dependencies:
	act -j test-dependencies --container-architecture linux/amd64

.PHONY: help update-dependencies test-dependencies
