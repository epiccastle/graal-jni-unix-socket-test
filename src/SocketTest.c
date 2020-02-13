#include <jni.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/un.h>
#include <sys/socket.h>
#include "SocketTest.h"

/*
 * Copy string src to buffer dst of size dsize.  At most dsize-1
 * chars will be copied.  Always NUL terminates (unless dsize == 0).
 * Returns strlen(src); if retval >= dsize, truncation occurred.
 */
size_t
custom_strlcpy(char * __restrict dst, const char * __restrict src, size_t dsize)
{
        const char *osrc = src;
        size_t nleft = dsize;

        /* Copy as many bytes as will fit. */
        if (nleft != 0) {
                while (--nleft != 0) {
                        if ((*dst++ = *src++) == '\0')
                                break;
                }
        }

        /* Not enough room in dst, add NUL and traverse rest of src. */
        if (nleft == 0) {
                if (dsize != 0)
                        *dst = '\0';		/* NUL-terminate dst */
                while (*src++)
                        ;
        }

        return(src - osrc - 1);	/* count does not include NUL */
}


/*
 * Class:     SocketTest
 * Method:    print
 * Signature: ()V
 */
JNIEXPORT void JNICALL
Java_SocketTest_print(JNIEnv *env, jobject obj) {

        printf("Hello world; this is C talking!\n");
        return;
}

/*
 * Class:     SocketTest
 * Method:    open_unix_socket
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_SocketTest_open_1unix_1socket
  (JNIEnv *env, jclass this, jstring path)
{
  const char* cpath = (*env)->GetStringUTFChars(env, path, 0);

  struct sockaddr_un sunaddr;
  memset(&sunaddr, 0, sizeof(sunaddr));
  sunaddr.sun_family = AF_UNIX;
  custom_strlcpy(sunaddr.sun_path, cpath, sizeof(sunaddr.sun_path));

  (*env)->ReleaseStringUTFChars(env, path, cpath);

  int sock = socket(AF_UNIX, SOCK_STREAM, 0);
  if(sock == -1)
    {
      // error: failed to allocate unix domain socket
      return (jint)-1;
    }

  if(fcntl(sock, F_SETFD, FD_CLOEXEC) == -1 ||
     connect(sock, (struct sockaddr *)&sunaddr, sizeof(sunaddr)) == -1)
    {
      close(sock);
      return (jint)-1;
    }

  return (jint)sock;
}

/*
 * Class:     SocketTest
 * Method:    close_unix_socket
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_SocketTest_close_1unix_1socket
  (JNIEnv *env, jclass this, jint fd)
{
  close((int)fd);
}

/*
 * Class:     SocketTest
 * Method:    unix_socket_read
 * Signature: (I[BI)I
 */
JNIEXPORT jint JNICALL Java_SocketTest_unix_1socket_1read
  (JNIEnv *env, jclass this, jint fd, jbyteArray buf, jint count)
{
  jbyte buffer[count];
  int bytes_read = read(fd, (void *)buffer, count);
  (*env)->SetByteArrayRegion(env, buf, 0, bytes_read, buffer);
  return bytes_read;
}

/*
 * Class:     SocketTest
 * Method:    unix_socket_write
 * Signature: (I[BI)I
 */
JNIEXPORT jint JNICALL Java_SocketTest_unix_1socket_1write
  (JNIEnv *env, jclass this, jint fd, jbyteArray buf, jint count)
{
  jboolean copy = 1;
  jbyte *buffer = (*env)->GetByteArrayElements(env, buf, &copy);
  int bytes_writen = write(fd, (const void *)buffer, count);
  (*env)->ReleaseByteArrayElements(env, buf, buffer, JNI_ABORT);
  return bytes_writen;
}
