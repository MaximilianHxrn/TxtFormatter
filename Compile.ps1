javac Formatter.java
jar cfm Formatter.jar manifest.txt *.class
Remove-Item -path ".\*.class"
& 'Z:\Transfer\sit.mh\mingw-w64\i686-8.1.0-posix-dwarf-rt_v6-rev0\mingw32\bin\g++.exe' -g Formatter.cpp -o Formatter.exe