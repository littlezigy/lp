SHELL := /bin/bash

ifndef LIGO
	LIGO=$(HOME)/ligo
endif

unit_tests:
	$(LIGO) run test tests/unit_tests/index.mligo 
system_tests:
	$(LIGO) run test tests/system_tests/index.mligo 
test:
	$(LIGO) run test tests/index.mligo 
