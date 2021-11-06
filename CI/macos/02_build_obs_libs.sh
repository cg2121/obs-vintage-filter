#!/bin/bash

##############################################################################
# macOS libobs library build function
##############################################################################
#
# This script file can be included in build scripts for macOS or run directly
#
##############################################################################

# Halt on errors
set -eE

build_obs_libs() {
    status "Build libobs and obs-frontend-api"
    trap "caught_error 'build_obs_libs'" ERR

    ensure_dir "${OBS_BUILD_DIR}"

    step "Configuring OBS build system"
    check_ccache
    cmake -S . -B plugin_${BUILD_DIR} -G Ninja ${CMAKE_CCACHE_OPTIONS} \
        -DCMAKE_OSX_ARCHITECTURES="${CMAKE_ARCHS}" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-${CI_MACOSX_DEPLOYMENT_TARGET}} \
        -DOBS_CODESIGN_LINKER=${CODESIGN_LINKER:-OFF} \
        -DCMAKE_BUILD_TYPE=${BUILD_CONFIG} \
        -DENABLE_PLUGINS=OFF \
        -DENABLE_UI=ON \
        -DENABLE_SCRIPTING=OFF \
        -DCMAKE_PREFIX_PATH="${DEPS_BUILD_DIR}/obs-deps" \
        ${QUIET:+-Wno-deprecated -Wno-dev --log-level=ERROR}

    step "Building libobs and obs-frontend-api"
    cmake --build plugin_${BUILD_DIR} -t obs-frontend-api
}

build-obs-libs-standalone() {
    CHECKOUT_DIR="$(/usr/bin/git rev-parse --show-toplevel)"
    if [ -f "${CHECKOUT_DIR}/CI/include/build_environment.sh" ]; then
        source "${CHECKOUT_DIR}/CI/include/build_environment.sh"
    fi
    PRODUCT_NAME="${PRODUCT_NAME:-obs-plugin}"
    OBS_BUILD_DIR="${CHECKOUT_DIR}/../obs-studio"
    source "${CHECKOUT_DIR}/CI/include/build_support.sh"
    source "${CHECKOUT_DIR}/CI/include/build_support_macos.sh"

    check_macos_version
    check_archs
    build_obs_libs
}

print_usage() {
    echo -e "Usage: ${0}\n" \
            "-h, --help                     : Print this help\n" \
            "-q, --quiet                    : Suppress most build process output\n" \
            "-v, --verbose                  : Enable more verbose build process output\n" \
            "-a, --architecture             : Specify build architecture (default: universal, alternative: x86_64, arm64)\n" \
            "--build-dir                    : Specify alternative build directory (default: build)\n"
}

build-obs-libs-main() {
    if [ -z "${_RUN_OBS_BUILD_SCRIPT}" ]; then
        while true; do
            case "${1}" in
                -h | --help ) print_usage; exit 0 ;;
                -q | --quiet ) export QUIET=TRUE; shift ;;
                -v | --verbose ) export VERBOSE=TRUE; shift ;;
                -a | --architecture ) ARCH="${2}"; shift 2 ;;
                --build-dir ) BUILD_DIR="${2}"; shift 2 ;;
                -- ) shift; break ;;
                * ) break ;;
            esac
        done

        build-obs-libs-standalone
    fi
}

build-obs-libs-main $*
