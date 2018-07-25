#!make
include .env
export $(shell sed 's/=.*//' .env)

version=$(v)
project_name=MyProject

export_token:
	@export GITHUB_TOKEN=$(GITHUB_TOKEN)

check_for_version:
	@[ "${v}" ] || ( echo ">> v is not set, set a version like v=0.3.0"; exit 1 )

release:
	@make check_for_version
	@echo "Releasing $(project_name) v$(version)"
	@make zip
	@make tag
	@make create_release
	@make upload
	@make remove_zip

zip:
	@zip dist.zip dist/*

remove_zip:
	@rm -rf dist.zip

tag:
	@git tag $(version)
	@git push --tags

create_release:
	@gothub release \
	-u nonoesp \
	-r test-a \
	--tag $(version) \
	--name "$(project_name) v$(version)" \
	--description "Description here."

upload:
	@gothub upload \
	-u nonoesp \
	-r test-a \
	--tag $(version) \
	--name "$(project_name)-v$(version).zip" \
	--file dist.zip