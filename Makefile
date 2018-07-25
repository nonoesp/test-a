#!make
include .env
export $(shell sed 's/=.*//' .env)

# Auto-release script
# Nono Martínez Alonso (@nonoesp)

# For this to work, you need to set the GITHUB_TOKEN
# variable inside your .env, make sure to .gitignore
# .env to avoid exposing your token

# Here is how to generate a token on GitHub
# https://help.github.com/articles/creating-an-access-token-for-command-line-use

# variables

version=$(v)
project_name=TestProject
release_notes=`cat release_notes.md`
username=nonoesp
repository=test-a

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
	@mv dist $(project_name)
	@zip $(project_name).zip $(project_name)/*
	@mv $(project_name) dist

delete_zip:
	@rm -rf $(project_name).zip

tag:
	@git tag $(version)
	@git push --tags

delete_tag:
	@git push origin :$(version)
	@git tag --delete $(version)

create_release:
	@gothub release \
	-u $(username) \
	-r $(repository) \
	--tag $(version) \
	--name "$(project_name) v$(version)" \
	--description "$(release_notes)"

delete_release:
	@gothub delete \
	-u $(username) \
	-r $(repository) \
	--tag $(v)

upload:
	@gothub upload \
	-u $(username) \
	-r $(repository) \
	--tag $(version) \
	--name "$(project_name)-v$(version).zip" \
	--file $(project_name).zip