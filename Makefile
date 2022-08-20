SHELL := /bin/bash

ifndef LIGO
	LIGO=$(HOME)/ligo
endif

unit_tests:
	$(LIGO) run test tests/unit/index.mligo 

test:
	$(LIGO) run test tests/index.mligo 
