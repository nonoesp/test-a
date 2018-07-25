#!make
include .env
export $(shell sed 's/=.*//' .env)

version=$(v)

export_token:
	@export GITHUB_TOKEN=$(GITHUB_TOKEN)

release:
	echo "Make a release $(version)."
	make zip
	make tag
	make create_release
	make upload
	make remove_zip

zip:
	zip dist.zip dist/*

remove_zip:
	rm -rf dist.zip

tag:
	git tag $(version)
	git push --tags

create_release:
	gothub release \
	-u nonoesp \
	-r test-a \
	--tag $(version) \
	--name "Repo v$(version)" \
	--description "Description here."

upload:
	gothub upload \
	-u nonoesp \
	-r test-a \
	--tag $(version) \
	--name "repo-v$(version).zip" \
	--file dist.zip