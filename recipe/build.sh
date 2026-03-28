set -ex

# Requires.private and Libs.private
# Are not meaningful in the context of shared libraries for conda-forge
# We thus "remove them" outright to avoid
# burdening the recipe
# https://github.com/conda-forge/harfbuzz-feedstock/pull/146
# https://github.com/conda-forge/conda-forge.github.io/issues/1880
find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
    -e '/^Requires\.private/d' \
    -e '/^Libs\.private/d' \
    {} +
find "${PREFIX}/lib/pkgconfig" -type f -name '*.bak' -delete

# This creates a standalone shared library that mimics the results
# of configuring qt with the flag `-gtk`
#
# By creating this standalone package, we simplify the proces of
# rebuilding qt due to requiring fewer dependencies for the main package
# requiring fewer bumps when the version changes.
# The CMakeLists.txt file was inspired by the one from Fedora
# https://github.com/FedoraQt/QGnomePlatform
# and is likely to work for qt6
cp -R src/plugins/platformthemes/gtk3/ qgtk3
cd qgtk3
cp ${RECIPE_DIR}/gtk_theme_CMakeLists.txt CMakeLists.txt

mkdir -p build
cd build

cmake ${CMAKE_ARGS}                 \
    -DQT_HOST_PATH=${PREFIX}        \
    -DCMAKE_PREFIX_PATH=${PREFIX}   \
    ..

make -j${CPU_COUNT}
make install
