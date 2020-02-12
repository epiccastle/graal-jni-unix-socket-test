#include <jni.h>
#include <stdio.h>
#include "SocketTest.h"

JNIEXPORT void JNICALL
Java_SocketTest_print(JNIEnv *env, jobject obj) {

        printf("Hello world; this is C talking!\n");
        return;
}
