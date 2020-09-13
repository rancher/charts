ci: bootstrap
	./scripts/ci

prepare: bootstrap
	./scripts/prepare

bootstrap:
	./scripts/bootstrap

charts: bootstrap prepare
	./scripts/generate-charts

patch: bootstrap
	./scripts/generate-patch

validate: bootstrap
	./scripts/validate

mirror: bootstrap
	./scripts/image-mirror

clean:
	./scripts/clean

rebase-patch:
	./scripts/generate-rebased-patch

rebase-patch-non-interactive:
	./scripts/generate-rebased-patch --non-interactive

.DEFAULT_GOAL := ci

