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
    public static native int unix_socket_write(int fd, int count, byte[] buf);

    // entry point
    public static void main(String[] args) {

        // instead we System.loadLibrary() inside the execution path
        // to load the library file
        System.loadLibrary("SocketTest");

        SocketTest test = new SocketTest();

        // connected?
        test.print();

        int fd = test.open_unix_socket("socket");

        System.out.println("opened fd: "+fd);

        System.out.println("writing to fd...");

        byte[] buff = "hello, world!\n".getBytes();
        int bytes_written = test.unix_socket_write(fd, buff.length, buff);

        System.out.println("bytes written (should be "+buff.length+"): "+bytes_written);

        test.close_unix_socket(fd);

        System.out.println("closed fd: "+fd);

        if(bytes_written != buff.length) {
            System.out.println("Test FAILED!");
            System.exit(1);
        }

        System.out.println("Test passed!");

    }

}
