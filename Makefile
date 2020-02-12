GRAALVM = $(HOME)/graalvm-ce-java11-19.3.1
ifneq (,$(findstring java11,$(GRAALVM)))
	JAVA_VERSION = 11
else
	JAVA_VERSION = 8
endif

clean:
	-rm src/*.class
	-rm src/*.h
	-rm *.jar
	-rm *.so
	-rm sockettest

src/SocketTest.class: src/SocketTest.java
	javac src/SocketTest.java

src/SocketTest.h: src/SocketTest.java
ifeq ($(JAVA_VERSION),8)
	cd src && javah -o SocketTest.h -cp ./ SocketTest
else
	cd src && javac -h ./ SocketTest.java
endif

libSocketTest.so: src/SocketTest.h src/SocketTest.c
	gcc -shared -Wall -Werror -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/linux -o libSocketTest.so -fPIC src/SocketTest.c

SocketTest.jar: src/SocketTest.class src/manifest.txt
	cd src && jar cfm ../SocketTest.jar manifest.txt SocketTest.class

run-jar: SocketTest.jar libSocketTest.so
	LD_LIBRARY_PATH=./ java -jar SocketTest.jar

sockettest: SocketTest.jar libSocketTest.so
	$(GRAALVM)/bin/native-image \
		-jar SocketTest.jar \
		-H:Name=sockettest \
		-H:+ReportExceptionStackTraces \
		-H:ConfigurationFileDirectories=config-dir \
		--initialize-at-build-time \
		--verbose \
		--no-fallback \
		--no-server \
		"-J-Xmx1g"

#		-H:+TraceClassInitialization -H:+PrintClassInitialization

run-native: sockettest libSocketTest.so
	LD_LIBRARY_PATH=./ ./sockettest
