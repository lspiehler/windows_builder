mkisofs with storage optimization

Alex Kopylov integrated his Duplicate files linker (DFL) to cdrtools in 2004.
http://bootcd.narod.ru/index_e.htm

Files are hosted at a archive:
http://web.archive.org/web/20070630200349/bcdw.wolfgang-brinkmann.de/downloads/cdrtools.htm

New options:
  -duplicates-once	Optimize storage by encoding duplicate files once
  -force-uppercase	Do not allow lower case characters

There may be strange side effects. In doubt use the official version.

=======================================================================

Official cdrtools:
http://cdrecord.berlios.de/
ftp://ftp.berlios.de/pub/cdrecord/

=======================================================================

Modified Modified mkisofs:

Compile sources at Cygwin environment. http://www.cygwin.com

Or compile sources at Tuma MinGW
http://opensourcepack.blogspot.com/p/cdrtools.html
http://opensourcepack.blogspot.com/p/tuma-mingw.html

El Torito 0x03 fake 2.88 floppy image:
80 < Tracks <= 1024, 2 Heads, 36 Sectors per track

$ bunzip2 < cdrtools-3.01a23.tar.bz2  | tar -xpf -
$ patch -p 0 < cdrtools-3.01a23.bootcd.ru.diff
$ cd cdrtools-3.01
$ make GMAKE_NOWARN=true
