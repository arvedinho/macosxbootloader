
PROJECT_DIR = $(PWD)

INCLUDES = -I /usr/include -I $(PROJECT_DIR)/sdk/include -I $(PROJECT_DIR)/sdk/include/x64 -I $(PROJECT_DIR)/src/include

ARCHFLAGS = -arch x86_64
ARCHLDFLAGS = -u ?EfiMain@@YA_KPEAXPEAU_EFI_SYSTEM_TABLE@@@Z -e ?EfiMain@@YA_KPEAXPEAU_EFI_SYSTEM_TABLE@@@Z

ARCHCFLAGS = -target x86_64-pc-win32-macho -funsigned-char -fno-ms-extensions -fno-stack-protector -fno-builtin -fshort-wchar -mno-implicit-float -msoft-float -mms-bitfields -ftrap-function=undefined_behavior_has_been_optimized_away_by_clang -D__x86_64__=1

AR = ar
CC = gcc
CXX = g++
LD = ld

NASM = $(PROJECT_DIR)/tools/nasm
NASMFLAGS = -f macho64 -DARCH64 -DAPPLEUSE
NASMCOMPFLAGS = -Daes_encrypt=_aes_encrypt -Daes_decrypt=_aes_decrypt

MTOC = $(PROJECT_DIR)/tools/mtoc -subsystem UEFI_APPLICATION -align 0x20

RANLIB = ranlib

STRIP = strip

WFLAGS = -Wall -Werror -Wno-unknown-pragmas

CFLAGS = "$(WFLAGS) $(DEBUGFLAGS) $(ARCHFLAGS) -fborland-extensions $(ARCHCFLAGS) -fpie -std=gnu11 -Oz -DEFI_SPECIFICATION_VERSION=0x0001000a -DTIANO_RELEASE_VERSION=1 $(INCLUDES) -D_MSC_EXTENSIONS=1 -fno-exceptions" 

CXXFLAGS = "$(WFLAGS) $(DEBUGFLAGS) $(ARCHFLAGS) -fborland-extensions $(ARCHCFLAGS) -fpie -Oz -DEFI_SPECIFICATION_VERSION=0x0001000a -DTIANO_RELEASE_VERSION=1 $(INCLUDES) -D_MSC_EXTENSIONS=1 -fno-exceptions -std=gnu++11"

LDFLAGS = "$(ARCHFLAGS) -preload -segalign 0x20 $(ARCHLDFLAGS) -pie -all_load -dead_strip -image_base 0x240 -compatibility_version 1.0 -current_version 2.1 -flat_namespace -print_statistics -map boot.map -sectalign __TEXT __text 0x20  -sectalign __TEXT __eh_frame  0x20 -sectalign __TEXT __ustring 0x20  -sectalign __TEXT __const 0x20   -sectalign __TEXT __ustring 0x20 -sectalign __DATA __data 0x20  -sectalign __DATA __bss 0x20  -sectalign __DATA __common 0x20 -final_output boot.efi"


all: rijndael x64 boot

rijndael:
	cd src/rijndael && make -f Makefile ARCH="$(ARCH)" NASM="$(NASM)" NASMFLAGS="$(NASMFLAGS)" CC="$(CC)" CFLAGS=$(CFLAGS) AR="$(AR)" RANLIB="$(RANLIB)" NASMCOMPFLAGS="$(NASMCOMPFLAGS)"  && cd ../..

x64:
	cd src/boot/x64 && make CXX="$(CXX)" CXXFLAGS=$(CXXFLAGS) NASM="$(NASM)" NASMFLAGS="$(NASMFLAGS)" AR="$(AR)" RANLIB="$(RANLIB)" && cd ../../..

boot:
	cd src/boot && make CC="$(CC)" CFLAGS=$(CFLAGS) CXX="$(CXX)" ARCH=$(ARCH) CXXFLAGS=$(CXXFLAGS) LD="$(LD)" LDFLAGS=$(LDFLAGS) STRIP="$(STRIP)" MTOC="$(MTOC)" && cd ../..

clean:
	cd src/rijndael && make clean && cd ../..
	cd src/boot && make clean && cd ../..
	cd src/boot/x64 && make clean && cd ../../..
	cd src/boot/x86 && make clean && cd ../../..
