# make run FLAVOR=dev          (dev|staging|prod; default dev)
# make build-apk FLAVOR=prod   build-appbundle / build-ipa likewise
# make codegen                  build_runner once
#
# Each flavor reads .env.<flavor> (git-ignored; copy from .env.example).
FLAVOR ?= dev
# ISPECT_ENABLED compiles the debug inspector in (logging module) — never for prod.
DEFINES = --dart-define=FLAVOR=$(FLAVOR) --dart-define-from-file=.env.$(FLAVOR) \
  --dart-define=ISPECT_ENABLED=$(if $(filter prod,$(FLAVOR)),false,true)

.PHONY: run codegen build-apk build-appbundle build-ipa

run:
	flutter run $(DEFINES)

codegen:
	flutter pub run build_runner build

build-apk:
	flutter build apk --release $(DEFINES)

build-appbundle:
	flutter build appbundle --release $(DEFINES)

build-ipa:
	flutter build ipa --release $(DEFINES)
