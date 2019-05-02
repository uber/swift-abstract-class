BINARY_FOLDER_PREFIX?=/usr/local
BINARY_FOLDER=$(BINARY_FOLDER_PREFIX)/bin/
VALIDATOR_FOLDER=Validator
VALIDATOR_ARCHIVE_PATH=$(shell cd $(VALIDATOR_FOLDER) && swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/abstractclassvalidator
VALIDATOR_VERSION_FOLDER_PATH=$(VALIDATOR_FOLDER)/Sources/abstractclassvalidator
VALIDATOR_VERSION_FILE_PATH=$(VALIDATOR_VERSION_FOLDER_PATH)/Version.swift
SWIFT_BUILD_FLAGS=--disable-sandbox -c release -Xswiftc -static-stdlib

.PHONY: clean build install uninstall

clean:
	cd $(VALIDATOR_FOLDER) && swift package clean

build:
	cd $(VALIDATOR_FOLDER) && swift build $(SWIFT_BUILD_FLAGS)

install: uninstall clean build
	install -d "$(BINARY_FOLDER)"
	install "$(VALIDATOR_ARCHIVE_PATH)" "$(BINARY_FOLDER)"

uninstall:
	rm -f "$(BINARY_FOLDER)/abstractclassvalidator"
	rm -f "/usr/local/bin/abstractclassvalidator"

publish:
	git checkout master
	$(eval NEW_VERSION := $(filter-out $@, $(MAKECMDGOALS)))
	@sed 's/__VERSION_NUMBER__/$(NEW_VERSION)/g' $(VALIDATOR_VERSION_FOLDER_PATH)/Version.swift.template > $(VALIDATOR_VERSION_FILE_PATH)
%:
	@:
	sed -i '' "s/\(s.version.*=.*'\).*\('\)/\1$(NEW_VERSION)\2/" AbstractClassFoundation.podspec
	make archive_validator
	git add $(VALIDATOR_FOLDER)/bin/abstractclassvalidator
	git add $(VALIDATOR_VERSION_FILE_PATH)
	git add AbstractClassFoundation.podspec
	$(eval NEW_VERSION_TAG := v$(NEW_VERSION))
	git commit -m "Update validator binary and version file for $(NEW_VERSION_TAG)"
	git push origin master
	git tag $(NEW_VERSION_TAG)
	git push origin $(NEW_VERSION_TAG)
	$(eval NEW_VERSION_SHA := $(shell git rev-parse $(NEW_VERSION_TAG)))
	# Disabled until the project gets more traction so we can release it on brew.
	# brew update && brew bump-formula-pr --tag=$(NEW_VERSION_TAG) --revision=$(NEW_VERSION_SHA) abstractclassvalidator
	pod trunk push

archive_validator: clean build
	mv $(VALIDATOR_ARCHIVE_PATH) $(VALIDATOR_FOLDER)/bin/
