# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "FastJetBuilder"

# Collection of sources required to build FastJetBuilder
sources = [
    "http://www.fastjet.fr/repo/fastjet-3.3.2.tar.gz" =>
    "3f59af13bfc54182c6bb0b0a6a8541b409c6fda5d105f17e03c4cce8db9963c2",

]

# Bash recipe for building across all platforms
# FIXME
# because the libs don't have their dependencies specified properly, 
# we're hacking the libs together into a single one for the time being
script = raw"""
cd $WORKSPACE/srcdir/fastjet-*/
CC=`which gcc`
CXX=`which g++`
./configure --prefix=$prefix --host=$target
make
make install
cd ${prefix}/lib
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11)),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8, :cxx11)),
]

platforms = expand_gcc_versions(platforms)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libsiscone", :libsiscone),
    LibraryProduct(prefix, "libfastjet", :libfastjet),
    LibraryProduct(prefix, "libfastjettools", :libfastjettools),
    LibraryProduct(prefix, "libsiscone_spherical", :libsisconeSpherical),
    LibraryProduct(prefix, "libfastjetplugins", :libfastjetplugins)
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

version_number = get(ENV, "TRAVIS_TAG", "")
if version_number == ""
    version_number = "v0.99"
end

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, VersionNumber(version_number), sources, script, platforms, products, dependencies)

