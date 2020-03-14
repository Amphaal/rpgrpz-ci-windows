git clone https://github.com/Amphaal/rpgrpz.git
cd rpgrpz
cmake -GNinja -B_genRelease -H. -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/windows-ci.cmake