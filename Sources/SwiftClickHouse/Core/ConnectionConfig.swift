import Foundation;

public class ConnectionConfig {
    public let host : String;
    public let port : UInt32;
    public let user : String;
    public let password : String;
    public let database : String;
    public let compression : CompressionState;

    public init(host : String = "localhost", port : Int32 = 9000, database : String = "default", user : String = "default", password : String = "", compression : CompressionState = .Disable) {
        self.host        = host;
        self.user        = user;
        self.password    = password;
        self.database    = database;
        self.port        = port;
        self.compression = compression;
    }
}
