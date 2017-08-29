#! /bin/bash
# by pts@fazekas.hu at Thu Aug 17 20:31:00 CEST 2017
#
# Needs qpdf >= 9a96e233b051b31289c84f90a321583887b1400a
# Tested with qpdf 201b62fc68398b37decbe0fde24dc94486db244e
#
# TODO(pts): Why is qpdf.exe much larger than qpdf.darwinc32 and
# qpdf.xstatic? Probably because of the older gcc in i586-mingw32msvc-gcc?
#

set -ex

rm -f *.o
rm -rf src
mkdir src
(cd src && tar xjvf ../from-qpdf-201b62fc68398b37decbe0fde24dc94486db244e.tar.bz2) || exit "$?"
(cd src && patch -p0 -f <../pts-qpdf-findendstream.patch) || exit "$?"
(cd src && patch -p0 -f <../pts-sign-cast.patch) || exit "$?"

cp qpdf-config-xstatic.h src/libqpdf/qpdf/qpdf-config.h
i586-mingw32msvc-gcc -c -O2 -W -Wall -ansi \
    -ffunction-sections -fdata-sections -Dinline=__inline__ \
    src/libqpdf/sha2.c src/libqpdf/sha2big.c
i586-mingw32msvc-gcc -c -O2 -W -Wall -ansi -Izlib_src \
    -DNO_VIZ -DNO_DUMMY_DECL \
    -ffunction-sections -fdata-sections \
    zlib_src/zall.c
# We can't do -fno-exceptions, because qpdf uses exceptions.
# We can't do -fno-rtti, because qpdf uses dynamic_cast.
# We can't use -ansi, because ::swprintf is missing there.
# We can't use -Wold-stlye-cast, there is (HANDLE)... etc.
i586-mingw32msvc-g++ -s -O2 -Isrc/include -Isrc/libqpdf -Izlib_src \
    -W -Wall -Wno-unused-parameter \
    -ffunction-sections -fdata-sections -Wl,--gc-sections \
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
    -o qpdf.exe
rm -f *.o
ls -l qpdf.exe

: OK.
