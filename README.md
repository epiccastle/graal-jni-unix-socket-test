# graal-jni-unix-socket-test
Minimal test code to recreate failing macos unix domain socket failing writes

## Problem

JNI code writing to Unix domain sockets, when called from a graal native-image on MacOS, always writes 0 bytes.

## Running

### JVM

```shell
make run-jar-test
```

### native-image

```
make run-native-test
```

### cleaning

```
make clean
```

## Results

### Linux

#### JVM

```shell
$ java -version
openjdk version "11.0.5" 2019-10-15
OpenJDK Runtime Environment (build 11.0.5+10-post-Ubuntu-2ubuntu116.04)
OpenJDK 64-Bit Server VM (build 11.0.5+10-post-Ubuntu-2ubuntu116.04, mixed mode, sharing)

$ make clean
rm src/*.class
rm src/*.h
rm *.jar
rm *.so
rm sockettest

$ make run-jar-test
javac src/SocketTest.java
cd src && jar cfm ../SocketTest.jar manifest.txt SocketTest.class
cd src && javac -h ./ SocketTest.java
gcc -shared -Wall -Werror -I/usr/lib/jvm/java-8-oracle/include -I/usr/lib/jvm/java-8-oracle/include/linux -o libSocketTest.so -fPIC src/SocketTest.c
nc -l -U socket & \
LD_LIBRARY_PATH=./ java -jar SocketTest.jar
Hello world; this is C talking!
opened fd: 6
writing to fd...
hello, world!
bytes written (should be 14): 14
closed fd: 6
Test passed!
```

#### Native Image

```shell
$ make clean
rm src/*.class
rm src/*.h
rm *.jar
rm *.so
rm sockettest

$ make run-native-test
javac src/SocketTest.java
cd src && jar cfm ../SocketTest.jar manifest.txt SocketTest.class
cd src && javac -h ./ SocketTest.java
gcc -shared -Wall -Werror -I/usr/lib/jvm/java-8-oracle/include -I/usr/lib/jvm/java-8-oracle/include/linux -o libSocketTest.so -fPIC src/SocketTest.c
/home/crispin/graalvm-ce-java11-19.3.1/bin/native-image \
    -jar SocketTest.jar \
    -H:Name=sockettest \
    -H:+ReportExceptionStackTraces \
    -H:ConfigurationFileDirectories=config-dir \
    --initialize-at-build-time \
    --verbose \
    --no-fallback \
    --no-server \
    "-J-Xmx1g"
Executing [
/home/crispin/graalvm-ce-java11-19.3.1/bin/java \
-XX:+UnlockExperimentalVMOptions \
-XX:+EnableJVMCI \
-Dtruffle.TrustAllTruffleRuntimeProviders=true \
-Dtruffle.TruffleRuntime=com.oracle.truffle.api.impl.DefaultTruffleRuntime \
-Dgraalvm.ForcePolyglotInvalid=true \
-Dgraalvm.locatorDisabled=true \
-Dsubstratevm.IgnoreGraalVersionCheck=true \
-Djava.lang.invoke.stringConcat=BC_SB \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.runtime=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.code=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.aarch64=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.amd64=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.meta=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.hotspot=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.services=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.common=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.code.site=ALL-UNNAMED \
--add-exports \
jdk.internal.vm.ci/jdk.vm.ci.code.stack=ALL-UNNAMED \
--add-opens \
jdk.internal.vm.compiler/org.graalvm.compiler.debug=ALL-UNNAMED \
--add-opens \
jdk.internal.vm.compiler/org.graalvm.compiler.nodes=ALL-UNNAMED \
--add-opens \
jdk.unsupported/sun.reflect=ALL-UNNAMED \
--add-opens \
java.base/jdk.internal.module=ALL-UNNAMED \
--add-opens \
java.base/jdk.internal.ref=ALL-UNNAMED \
--add-opens \
java.base/jdk.internal.reflect=ALL-UNNAMED \
--add-opens \
java.base/java.io=ALL-UNNAMED \
--add-opens \
java.base/java.lang=ALL-UNNAMED \
--add-opens \
java.base/java.lang.reflect=ALL-UNNAMED \
--add-opens \
java.base/java.lang.invoke=ALL-UNNAMED \
--add-opens \
java.base/java.lang.ref=ALL-UNNAMED \
--add-opens \
java.base/java.net=ALL-UNNAMED \
--add-opens \
java.base/java.nio=ALL-UNNAMED \
--add-opens \
java.base/java.nio.file=ALL-UNNAMED \
--add-opens \
java.base/java.security=ALL-UNNAMED \
--add-opens \
java.base/javax.crypto=ALL-UNNAMED \
--add-opens \
java.base/java.util=ALL-UNNAMED \
--add-opens \
java.base/java.util.concurrent.atomic=ALL-UNNAMED \
--add-opens \
java.base/sun.security.x509=ALL-UNNAMED \
--add-opens \
java.base/jdk.internal.logger=ALL-UNNAMED \
--add-opens \
org.graalvm.sdk/org.graalvm.nativeimage.impl=ALL-UNNAMED \
--add-opens \
org.graalvm.sdk/org.graalvm.polyglot=ALL-UNNAMED \
--add-opens \
org.graalvm.truffle/com.oracle.truffle.polyglot=ALL-UNNAMED \
--add-opens \
org.graalvm.truffle/com.oracle.truffle.api.impl=ALL-UNNAMED \
-XX:+UseJVMCINativeLibrary \
-Xss10m \
-Xms1g \
-Xmx14g \
-Duser.country=US \
-Duser.language=en \
-Dorg.graalvm.version=19.3.1 \
-Dorg.graalvm.config=CE \
-Dcom.oracle.graalvm.isaot=true \
--module-path \
/home/crispin/graalvm-ce-java11-19.3.1/lib/truffle/truffle-api.jar \
-javaagent:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/svm.jar \
-Djdk.internal.lambda.disableEagerInitialization=true \
-Djdk.internal.lambda.eagerlyInitialize=false \
-Djava.lang.invoke.InnerClassLambdaMetafactory.initializeLambdas=false \
-Xmx1g \
-cp \
/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/svm.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/svm-llvm.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/llvm-platform-specific-shadowed.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/javacpp-shadowed.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/graal-llvm.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/objectfile.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/llvm-wrapper-shadowed.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/pointsto.jar \
com.oracle.svm.hosted.NativeImageGeneratorRunner$JDK9Plus \
-watchpid \
4120 \
-imagecp \
/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/svm.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/svm-llvm.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/llvm-platform-specific-shadowed.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/javacpp-shadowed.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/graal-llvm.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/objectfile.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/llvm-wrapper-shadowed.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/builder/pointsto.jar:/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/library-support.jar:/home/crispin/dev/epiccastle/graal-jni-unix-socket-test/SocketTest.jar \
-H:Path=/home/crispin/dev/epiccastle/graal-jni-unix-socket-test \
-H:Class=SocketTest \
-H:+ReportExceptionStackTraces \
-H:ConfigurationFileDirectories=config-dir \
-H:ClassInitialization=:build_time \
-H:FallbackThreshold=0 \
-H:CLibraryPath=/home/crispin/graalvm-ce-java11-19.3.1/lib/svm/clibraries/linux-amd64 \
-H:Name=sockettest
]
[sockettest:4139]    classlist:   2,447.36 ms
[sockettest:4139]        (cap):   1,221.70 ms
[sockettest:4139]        setup:   3,558.06 ms
[sockettest:4139]   (typeflow):   7,756.13 ms
[sockettest:4139]    (objects):   5,474.05 ms
[sockettest:4139]   (features):     412.99 ms
[sockettest:4139]     analysis:  14,011.50 ms
[sockettest:4139]     (clinit):     285.10 ms
[sockettest:4139]     universe:     966.74 ms
[sockettest:4139]      (parse):   1,670.37 ms
[sockettest:4139]     (inline):   2,663.26 ms
[sockettest:4139]    (compile):  12,379.08 ms
[sockettest:4139]      compile:  17,731.98 ms
[sockettest:4139]        image:   1,715.86 ms
[sockettest:4139]        write:     235.56 ms
[sockettest:4139]      [total]:  41,074.04 ms
nc -l -U socket & \
LD_LIBRARY_PATH=./ ./sockettest
Hello world; this is C talking!
opened fd: 3
writing to fd...
bytes written (should be 14): 14hello, world!

closed fd: 3
Test passed!
```
