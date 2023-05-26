#
# Makefile
#

ALL_TARGETS   := $(shell find . -maxdepth 1 -type d | tr -d './' | egrep -v '^99' | sort)
ALL_TARGETS_R := $(shell find . -maxdepth 1 -type d | tr -d './' | egrep -v '^99' | sort -r)

deploy:
	@for target in $(ALL_TARGETS); do \
		echo ; \
		echo "*****************************************************"; \
		echo " $$target"; \
		echo "*****************************************************"; \
		make --no-print-directory -C $$target deploy; \
	done

remove:
	@for target in $(ALL_TARGETS_R); do \
		echo ; \
		echo "*****************************************************"; \
		echo " $$target"; \
		echo "*****************************************************"; \
		make --no-print-directory -C $$target remove; \
	done
