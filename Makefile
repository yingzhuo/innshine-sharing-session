timestamp := $(shell /bin/date "+%F %T")

github:
	@git add .
	@git commit -m "$(timestamp)"
	@git push

.PHONY: github