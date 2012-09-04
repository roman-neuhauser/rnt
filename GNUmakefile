# vim: ft=make ts=8 sts=2 sw=2 noet

RST2HTML?=$(call first_in_path,rst2html.py rst2html)

htmlfiles =	README.html

check:
	SHELL=$(SHELL) $(SHELL) ./run-tests.sh tests \
	  $$PWD/run-tests.sh \
	  $$PWD/run-test.sh

html: $(htmlfiles)

%.html: %.rest
	$(RST2HTML) $< $@

define first_in_path
  $(firstword $(wildcard \
    $(foreach p,$(1),$(addsuffix /$(p),$(subst :, ,$(PATH)))) \
  ))
endef

MAKEFLAGS =	--no-print-directory \
		--no-builtin-rules \
		--no-builtin-variables

.PHONY: check html
