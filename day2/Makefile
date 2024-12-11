test: day2.o
	"/Library/Developer/CommandLineTools/usr/bin/ld" -demangle -lto_library \
	/Library/Developer/CommandLineTools/usr/lib/libLTO.dylib -dynamic \
	-arch arm64 -platform_version macos 15.1 15.1 \
	-syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
	-o test -L/opt/homebrew/lib day2.o -lSDL2 \
	-lSystem /Library/Developer/CommandLineTools/usr/lib/clang/16/lib/darwin/libclang_rt.osx.a \
	-e _start

day2.o: day2.asm
	as -O0 -g day2.asm -o day2.o -I.
