SHELL=/bin/sh

CONNTRACK_EXPORTER_VERSION = 0.4

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf " \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


base_image_local: ## base_image_local
	docker build -t conntrack_exporter:local -f dockerfiles/Dockerfile_centos7_compiler .

compile_docker_local: ## base_image_local
	docker run --rm -v $$(pwd):/home/conntrack conntrack_exporter:local /bin/bash -c "bazel build -c dbg //:conntrack_exporter && cp -f bazel-bin/conntrack_exporter ."

build: ## build
	bazel build -c dbg //:conntrack_exporter
	cp -f bazel-bin/conntrack_exporter .

build_stripped: ## build_stripped
	bazel build --strip=always -c opt //:conntrack_exporter
	cp -f bazel-bin/conntrack_exporter .

# May need to run make via sudo for this:
run: ## run
	./conntrack_exporter

docker_build_base: ## docker_build_base
	docker build -t ordenador/conntrack_exporter_compiler:$(CONNTRACK_EXPORTER_VERSION)-centos7 -f dockerfiles/Dockerfile_centos7_compiler .
	docker build -t ordenador/conntrack_exporter_compiler:$(CONNTRACK_EXPORTER_VERSION)-ubuntu -f dockerfiles/Dockerfile_ubuntu_compiler .

compiler_run_docker: docker_build_base ## compiler_run_docker
	docker run --rm -v $$(pwd):/home/conntrack ordenador/conntrack_exporter_compiler:$(CONNTRACK_EXPORTER_VERSION)-centos7 \
		/bin/bash -c "bazel build -c dbg //:conntrack_exporter && cp -f bazel-bin/conntrack_exporter ."
	tar -czf conntrack_exporter-v$(CONNTRACK_EXPORTER_VERSION).linux-amd64.tar.gz conntrack_exporter

build_docker: compiler_run_docker ## build_docker
	docker build -t ordenador/conntrack_exporter:$(CONNTRACK_EXPORTER_VERSION)-centos7 -f dockerfiles/Dockerfile_centos7 .
	docker build -t ordenador/conntrack_exporter:$(CONNTRACK_EXPORTER_VERSION)-ubuntu -f dockerfiles/Dockerfile_ubuntu .

run_docker: ## run_docker
	docker run -it --rm \
		--cap-add=NET_ADMIN \
		--name=conntrack_exporter \
		--net=host \
		ordenador/conntrack_exporter:$(CONNTRACK_EXPORTER_VERSION)-centos7

publish_docker: build_docker ## publish_docker
	docker push ordenador/conntrack_exporter_compiler:$(CONNTRACK_EXPORTER_VERSION)-centos7
	docker push ordenador/conntrack_exporter_compiler:$(CONNTRACK_EXPORTER_VERSION)-ubuntu
	docker push ordenador/conntrack_exporter:$(CONNTRACK_EXPORTER_VERSION)-centos7
	docker push ordenador/conntrack_exporter:$(CONNTRACK_EXPORTER_VERSION)-ubuntu
	docker tag ordenador/conntrack_exporter:$(CONNTRACK_EXPORTER_VERSION)-centos7 ordenador/conntrack_exporter:latest
	docker push ordenador/conntrack_exporter:latest


clean: base_image_local ## clean
	docker run --rm -v $$(pwd):/home/conntrack conntrack_exporter:local /bin/bash -c "bazel clean"
	rm -fr .cache
	rm -fr .pki
	rm -f conntrack_exporter
	rm -f conntrack_exporter-v$(CONNTRACK_EXPORTER_VERSION).linux-amd64.tar.gz
	docker rmi -f $$(docker images | grep 'conntrack_exporter' | awk '{print $$3}')
