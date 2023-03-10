.DEFAULT_GOAL := help

## ONESHELL makes Make to use singe shell sessions for command lines defined in targets.
## We use it here to inline bash scripts, like in remove-invert-match target
.ONESHELL:

checkout-branch: ## Checkout to the branch
	set -e
	test -n "$(BRANCH_NAME)" || (echo "BRANCH_NAME is not set"; exit 1)

	set +e
	git fetch --all
	git checkout $$BRANCH_NAME
	if [ $$? -eq 1 ];
	then
		echo "branch $$BRANCH_NAME doesn't exist yet, we will create it"
		git checkout --orphan $$BRANCH_NAME

		# removing all git checked-in files keeping .gitignore
		# https://stackoverflow.com/questions/36753573/how-do-i-exclude-files-from-git-ls-files
		git rm -rf -- . ':!:.gitignore'
		
		git add .gitignore
		git commit -a -m "Init branch"
	fi
	
	set -e
	git checkout $$BRANCH_NAME
	git pull origin $$BRANCH_NAME

add-file: checkout-branch
	echo "123" > newfile

publish-files: add-file
	git add .
	git commit -a -m "added ${BRANCH_NAME} files"
	git push -u origin ${BRANCH_NAME}


help: # Yeah, it's not mine - https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'