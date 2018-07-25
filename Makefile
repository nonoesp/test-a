#!make
include .env
export $(shell sed 's/=.*//' .env)

# variables

version=$(v)
project_name=RefineryClient
release_notes=`cat release_notes.md`

# main

release:
	@make check_for_version
	@echo "Releasing $(project_name) v$(version)"
	@make zip
	@make tag
	@make create_release
	@make upload
	@make delete_zip

unrelease:
	@make check_for_version
	@echo "Deleting release $(project_name) v$(version)"
	@make delete_release
	@make delete_tag

# util

export_token:
	@export GITHUB_TOKEN=$(GITHUB_TOKEN)

check_for_version:
	@[ "${v}" ] || ( echo ">> v is not set, set a version like v=0.3.0"; exit 1 )


zip:
	@zip dist.zip dist/*

delete_zip:
	@rm -rf dist.zip

tag:
	@git tag $(version)
	@git push --tags

delete_tag:
	@git push origin :$(version)

create_release:
	@gothub release \
	-u nonoesp \
	-r test-a \
	--tag $(version) \
	--name "$(project_name) v$(version)" \
	--description "$(release_notes)"

delete_release:
	@gothub delete \
	-u nonoesp \
	-r test-a \
	--tag $(v)

upload:
	@gothub upload \
	-u nonoesp \
	-r test-a \
	--tag $(version) \
	--name "$(project_name)-v$(version).zip" \
	--file dist.zip