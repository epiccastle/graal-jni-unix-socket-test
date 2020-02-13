GRAALVM = $(HOME)/graalvm-ce-java11-19.3.1
JAVA_HOME = $(GRAALVM)
ifneq (,$(findstring java11,$(GRAALVM)))
	JAVA_VERSION = 11
else
	JAVA_VERSION = 8
endif
UNAME = $(shell uname)
ifeq ($(UNAME),Linux)
	LIB_FILE=$(SOLIB_FILE)
	INCLUDE_DIRS=$(shell find $(JAVA_HOME)/include -type d)
else ifeq ($(UNAME),FreeBSD)
	LIB_FILE=$(SOLIB_FILE)
	INCLUDE_DIRS=$(shell find $(JAVA_HOME)/include -type d)
else ifeq ($(UNAME),Darwin)
	LIB_FILE=$(DYLIB_FILE)
	INCLUDE_DIRS=$(shell find $(JAVA_HOME)/Contents/Home/include -type d)
endif
INCLUDE_ARGS=$(INCLUDE_DIRS:%=-I%) -I.
SOLIB_FILE=libSocketTest.so
DYLIB_FILE=libSocketTest.dylib
C_FILE=src/SocketTest.c
C_HEADER=src/SocketTest.h

clean:
	-rm src/*.class
	-rm src/*.h
	-rm *.jar
	-rm *.so
	-rm *.dynlib
	-rm sockettest

src/SocketTest.class: src/SocketTest.java
	javac src/SocketTest.java

src/SocketTest.h: src/SocketTest.java
ifeq ($(JAVA_VERSION),8)
	cd src && javah -o SocketTest.h -cp ./ SocketTest
else
	cd src && javac -h ./ SocketTest.java
endif

lib: $(LIB_FILE)

$(SOLIB_FILE): $(C_FILE) $(C_HEADER)
	$(CC) $(INCLUDE_ARGS) -shared $(C_FILE) -o $(SOLIB_FILE) -fPIC

$(DYLIB_FILE):  $(C_FILE) $(C_HEADER)
	$(CC) $(INCLUDE_ARGS) -dynamiclib -undefined suppress -flat_namespace $(C_FILE) -o $(DYLIB_FILE) -fPIC

SocketTest.jar: src/SocketTest.class src/manifest.txt
	cd src && jar cfm ../SocketTest.jar manifest.txt SocketTest.class

run-jar-test: SocketTest.jar lib
	nc -l -U socket & \
	LD_LIBRARY_PATH=./ java -jar SocketTest.jar

sockettest: SocketTest.jar lib
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

run-native-test: sockettest lib
	nc -l -U socket & \
	LD_LIBRARY_PATH=./ ./sockettest
