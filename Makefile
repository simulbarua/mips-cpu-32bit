.PHONY: test single-cycle pipeline soc clean
test:
	python3 scripts/test.py all
single-cycle:
	python3 scripts/test.py single-cycle
pipeline:
	python3 scripts/test.py pipeline
soc:
	python3 scripts/test.py soc
clean:
	rm -rf build
