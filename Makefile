mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

COCOAPODS_EXISTS:=$(shell gem list -i cocoapods)

BOOST_FRAMEWORK_PATH=boost-iosx/frameworks

.PHONY: cocoapads boost-build boost-clean librime-check librime-build librime-clean

cocoapods:
	$(info gem cocoapads check)
ifeq ($(COCOAPODS_EXISTS), true)
	$(info cocoapads installed)
else
	$(info need install cocoapads)
	sudo gem install cocoapods
endif

boost-build: cocoapods
	$(info boost build begin)
	${MAKE} -C boost-iosx build
	mkdir -p Frameworks && \
		cp -rf ${BOOST_FRAMEWORK_PATH}/boost_atomic.xcframework Frameworks && \
		cp -rf ${BOOST_FRAMEWORK_PATH}/boost_filesystem.xcframework Frameworks && \
		cp -rf ${BOOST_FRAMEWORK_PATH}/boost_regex.xcframework Frameworks

boost-clean:
	${MAKE} -C boost-iosx clean

librime-check:
	# brew install cmake
	@[ -f `which cmake` ] || { echo "Install cmake first"; exit 1; }

librime-build: librime-check
	# NOTE (fork, 2026-11-24): do NOT run `git submodule update --init` here.
	# The pinned boost-iosx commit d7517e2 no longer exists upstream
	# (force-pushed away), so updating the root submodules fails with
	# "not our ref". CI clones both submodules manually at valid refs
	# (see ci.yaml "Checkout submodules"); librime's own submodules are
	# initialized inside librimeBuild.sh.
	${mkfile_dir}/librimeBuild.sh

librime-clean:
	rm -rf ${mkfile_dir}/librime.patch.apply
	rm -rf librime Frameworks/lib*.xcframework lib/*