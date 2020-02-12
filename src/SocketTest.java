class SocketTest {
    // putting System.loadLibrary() here forces us
    // to mark this class to initialize at runtime
    // when building with native-image
    // https://github.com/oracle/graal/issues/1828
    //
    // static {
    //     System.loadLibrary("SocketTest");
    // }

    // just to test we can call JNI
    private native void print();

    // open a unix domain socket
    public static native int open_unix_socket(String path);

    // close a unix domain socket
    public static native void close_unix_socket(int socket);

    // read from a unix domain socket
    public static native int unix_socket_read(int fd, byte[] buf, int count);

    // write to a unix domain socket
    public static native int unix_socket_write(int fd, byte[] buf, int count);

    // entry point
    public static void main(String[] args) {

        // instead we System.loadLibrary() inside the execution path
        // to load the library file
        System.loadLibrary("SocketTest");

        new SocketTest().print();
    }

}
