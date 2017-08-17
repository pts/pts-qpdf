#! /bin/bash
# by pts@fazekas.hu at Thu Aug 17 20:31:00 CEST 2017
#
# Needs qpdf >= 9a96e233b051b31289c84f90a321583887b1400a
# Tested with qpdf 201b62fc68398b37decbe0fde24dc94486db244e
#

set -ex

# $ docker image ls --digests multiarch/crossbuild
# The image ID is also a digest, and is a computed SHA256 hash of the image configuration object, which contains the digests of the layers that contribute to the image's filesystem definition.
# REPOSITORY             TAG                 DIGEST                                                                    IMAGE ID            CREATED             SIZE
# multiarch/crossbuild   latest              sha256:84a53371f554a3b3d321c9d1dfd485b8748ad6f378ab1ebed603fe1ff01f7b4d   846ea4d99d1a        5 months ago        2.99 GB
  CCC="docker run -v $PWD:/workdir multiarch/crossbuild /usr/osxcross/bin/o32-clang -mmacosx-version-min=10.5 -c"
 CXXC="docker run -v $PWD:/workdir multiarch/crossbuild /usr/osxcross/bin/o32-clang++ -mmacosx-version-min=10.5 -c"
 CCLD="docker run -v $PWD:/workdir multiarch/crossbuild /usr/osxcross/bin/o32-clang -mmacosx-version-min=10.5 -Ldarwin_libgcc/i386-apple-darwin10/4.9.4 -lSystem -lgcc -lcrt1.10.5.o -nostdlib"
STRIP="docker run -v $PWD:/workdir multiarch/crossbuild /usr/osxcross/bin/i386-apple-darwin14-strip"
test -f darwin_libgcc/i386-apple-darwin10/4.9.4/libgcc.a

rm -f *.o
rm -rf src
mkdir src
(cd src && tar xjvf ../from-qpdf-201b62fc68398b37decbe0fde24dc94486db244e.tar.bz2) || exit "$?"
(cd src && patch -p0 -f <../pts-qpdf-findendstream.patch) || exit "$?"
(cd src && patch -p0 -f <../pts-sign-cast.patch) || exit "$?"

cp qpdf-config-xstatic.h src/libqpdf/qpdf/qpdf-config.h
$CCC -O2 -W -Wall -ansi \
    -ffunction-sections -fdata-sections -Dinline=__inline__ \
    src/libqpdf/sha2.c src/libqpdf/sha2big.c
$CCC -O2 -W -Wall -ansi -Izlib_src \
    -DNO_VIZ -DNO_DUMMY_DECL \
    -ffunction-sections -fdata-sections \
    zlib_src/zall.c
# We can't do -fno-exceptions, because qpdf uses exceptions.
# We can't do -fno-rtti, because qpdf uses dynamic_cast.
# We do -lgcc_eh for the symbol __Unwind_Resume.
# We don't do -Wold-style-cast, because libqpdf/sph/sph_types.h triggers it.
$CCLD -O2 -Isrc/include -Isrc/libqpdf -Izlib_src -ansi \
    -W -Wall -Wno-unused-parameter \
    -ffunction-sections -fdata-sections -Wl,-dead_strip \
    src/libqpdf/BitStream.cc src/libqpdf/BitWriter.cc \
    src/libqpdf/Buffer.cc src/libqpdf/BufferInputSource.cc \
    src/libqpdf/FileInputSource.cc src/libqpdf/InputSource.cc \
    src/libqpdf/InsecureRandomDataProvider.cc src/libqpdf/MD5.cc \
    src/libqpdf/OffsetInputSource.cc src/libqpdf/Pipeline.cc \
    src/libqpdf/Pl_AES_PDF.cc src/libqpdf/Pl_ASCII85Decoder.cc \
    src/libqpdf/Pl_ASCIIHexDecoder.cc src/libqpdf/Pl_Buffer.cc \
    src/libqpdf/Pl_Concatenate.cc src/libqpdf/Pl_Count.cc \
    src/libqpdf/Pl_Discard.cc src/libqpdf/Pl_Flate.cc \
    src/libqpdf/Pl_LZWDecoder.cc src/libqpdf/Pl_MD5.cc \
    src/libqpdf/Pl_PNGFilter.cc src/libqpdf/Pl_QPDFTokenizer.cc \
    src/libqpdf/Pl_RC4.cc src/libqpdf/Pl_SHA2.cc \
    src/libqpdf/Pl_StdioFile.cc src/libqpdf/QPDF.cc \
    src/libqpdf/QPDFExc.cc src/libqpdf/QPDFObjGen.cc \
    src/libqpdf/QPDFObject.cc src/libqpdf/QPDFObjectHandle.cc \
    src/libqpdf/QPDFTokenizer.cc src/libqpdf/QPDFWriter.cc \
    src/libqpdf/QPDFXRefEntry.cc src/libqpdf/QPDF_Array.cc \
    src/libqpdf/QPDF_Bool.cc src/libqpdf/QPDF_Dictionary.cc \
    src/libqpdf/QPDF_InlineImage.cc src/libqpdf/QPDF_Integer.cc \
    src/libqpdf/QPDF_Name.cc src/libqpdf/QPDF_Null.cc \
    src/libqpdf/QPDF_Operator.cc src/libqpdf/QPDF_Real.cc \
    src/libqpdf/QPDF_Reserved.cc src/libqpdf/QPDF_Stream.cc \
    src/libqpdf/QPDF_String.cc src/libqpdf/QPDF_encryption.cc \
    src/libqpdf/QPDF_linearization.cc src/libqpdf/QPDF_optimization.cc \
    src/libqpdf/QPDF_pages.cc src/libqpdf/QTC.cc src/libqpdf/QUtil.cc \
    src/libqpdf/RC4.cc src/libqpdf/SecureRandomDataProvider.cc \
    src/libqpdf/qpdf-c.cc src/libqpdf/rijndael.cc src/qpdf/qpdf.cc \
    sha2.o sha2big.o zall.o \
    -lstdc++ -lgcc_eh \
    -o qpdf.darwinc32
# Are these warnings relevant? Specifying -mdynamic-no-pic doesn't make them go away.
# ld: warning: could not create compact unwind for __Unwind_RaiseException: non-standard register 0 being saved in prolog
$STRIP qpdf.darwinc32
rm -f *.o
ls -l qpdf.darwinc32

: OK.
