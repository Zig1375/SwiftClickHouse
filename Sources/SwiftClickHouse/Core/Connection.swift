import Foundation
import Socket

public class Connection {
    static private let DBMS_VERSION_MAJOR : UInt64 = 1;
    static private let DBMS_VERSION_MINOR : UInt64 = 1;
    static private let REVISION : UInt64           = 54126;

    static public let DBMS_MIN_REVISION_WITH_TEMPORARY_TABLES         : UInt64 = 50264;
    static public let DBMS_MIN_REVISION_WITH_TOTAL_ROWS_IN_PROGRESS   : UInt64 = 51554;
    static public let DBMS_MIN_REVISION_WITH_BLOCK_INFO               : UInt64 = 51903;
    static public let DBMS_MIN_REVISION_WITH_CLIENT_INFO              : UInt64 = 54032;
    static public let DBMS_MIN_REVISION_WITH_SERVER_TIMEZONE          : UInt64 = 54058;
    static public let DBMS_MIN_REVISION_WITH_QUOTA_KEY_IN_CLIENT_INFO : UInt64 = 54060;

    private let socket : Socket;
    private var queryCounter : UInt64 = 0;
    private var serverInfo : ServerInfo? = nil;
    private let compression : CompressionState;


    public convenience init(host : String = "localhost", port : Int, database : String = "default", user : String = "default", password : String = "", compression : CompressionState = .Disable) throws {
        try self.init(host: host, port: Int32(port), database : database);
    }

    public init(host : String = "localhost", port : Int32 = 9000, database : String = "default", user : String = "default", password : String = "", compression : CompressionState = .Disable) throws {
        let config = ConnectionConfig(host : host, port : port, database : database, user : user, password: password, compression: compression);
        try self.init(config : config);
    }

    public init(config : ConnectionConfig) throws {
        let signature = try Socket.Signature(protocolFamily: .inet, socketType: .stream, proto: .tcp, hostname: config.host, port: config.port)
        self.socket = try Socket.create(connectedUsing: signature!)

        self.compression = config.compression;

        if (config.compression == CompressionState.Enable) {
            throw ClickHouseError.NotImplemented(message: "Compression not implemented");
        }

        try sendHello(database : config.database, user : config.user, password : config.password);
    }

    public var isConnected : Bool {
        return self.socket.isConnected && self.serverInfo != nil;
    }

    private func sendHello(database : String, user : String, password : String) throws {
        let buffer = ByteBuffer();
        buffer.add(ClientCodes.Hello);
        buffer.add("ClickHouse client");
        buffer.add(Connection.DBMS_VERSION_MAJOR);
        buffer.add(Connection.DBMS_VERSION_MINOR);
        buffer.add(Connection.REVISION);
        buffer.add(database);
        buffer.add(user);
        buffer.add(password);

        try socket.write(from: buffer.toData());
        guard let socketReader = try read(socket: socket) else {
            throw ClickHouseError.SocketError;
        }

        guard let code = socketReader.read() else {
            print("Unknown code");
            throw ClickHouseError.Unknown;
        }

        guard let scode = ServerCodes(rawValue: code) else {
            print("Unknown code");
            throw ClickHouseError.Unknown;
        }

        if (scode == ServerCodes.Exception) {
            try parseException(socketReader: socketReader);
        }

        if (scode == ServerCodes.Hello) {
            guard let name = socketReader.readString(),
                  let version_major = socketReader.read(),
                  let version_minor = socketReader.read(),
                  let revision = socketReader.read() else {
                throw ClickHouseError.Unknown;
            }

            var timezone : String? = nil;
            if (revision >= Connection.DBMS_MIN_REVISION_WITH_SERVER_TIMEZONE) {
                if let tz = socketReader.readString() {
                    timezone = tz;
                }
            }

            self.serverInfo = ServerInfo(name : name, version_major : version_major, version_minor : version_minor, revision : revision, timezone : timezone);
            return;
        }

        throw ClickHouseError.Unknown;
    }

    func parseException(socketReader : SocketReader) throws {
        let e = ClickHouseException();
        var current = e;

        while(true) {
            if let code : UInt32 = socketReader.readInt() {
                current.code = code;
            } else {
                throw ClickHouseError.Unknown;
            }

            if let name = socketReader.readString() {
                current.name = name;
            } else {
                throw ClickHouseError.Unknown;
            }

            if let display_text = socketReader.readString() {
                current.display_text = display_text;
            } else {
                throw ClickHouseError.Unknown;
            }

            if let stack_trace = socketReader.readString() {
                current.stack_trace = stack_trace;
            } else {
                throw ClickHouseError.Unknown;
            }

            guard let has_nested = socketReader.readByte() else {
                throw ClickHouseError.Unknown;
            }

            if (has_nested == 1) {
                current.nested = ClickHouseException();
                current = current.nested!;
            } else {
                break;
            }
        }

        print(e);
        throw ClickHouseError.Error(code: e.code, display_text: e.display_text, exception: e);
    }

    public func ping() throws -> Bool {
        if (!self.isConnected) {
            throw ClickHouseError.NotConnected;
        }

        let buffer = ByteBuffer();
        buffer.add(ClientCodes.Ping);

        try socket.write(from: buffer.toData());

        guard let socketReader = try read(socket: socket) else {
            throw ClickHouseError.SocketError;
        }

        guard let code = socketReader.read() else {
            print("Unknown code");
            throw ClickHouseError.Unknown;
        }

        guard let scode = ServerCodes(rawValue: code) else {
            print("Unknown code");
            throw ClickHouseError.Unknown;
        }

        if (scode == .Pong) {
            return true;
        }

        return false;
    }

    public func query(sql : String) throws -> ClickHouseResult? {
        try self.sendQuery(sql : sql);
        return try receivePacket();
    }

    private func sendQuery(sql : String) throws {
        if (!self.isConnected) {
            throw ClickHouseError.NotConnected;
        }

        let buffer = ByteBuffer();
        buffer.add(ClientCodes.Query);
        buffer.add(generateQueryId());

        if (self.serverInfo!.revision >= Connection.DBMS_MIN_REVISION_WITH_CLIENT_INFO) {
            buffer.addFixed(UInt8(1));    // query_kind
            buffer.add("");   // initial_user
            buffer.add("");   // initial_query_id
            buffer.add("[::ffff:127.0.0.1]:0");   // initial_address
            buffer.addFixed(UInt8(1));   // iface_type

            buffer.add("");   // os_user
            buffer.add("");   // client_hostname
            buffer.add("ClickHouse client");   // client_name

            buffer.add(Connection.DBMS_VERSION_MAJOR);
            buffer.add(Connection.DBMS_VERSION_MINOR);
            buffer.add(Connection.REVISION);

            if (self.serverInfo!.revision >= Connection.DBMS_MIN_REVISION_WITH_QUOTA_KEY_IN_CLIENT_INFO) {
                buffer.add(""); // quota_key
            }
        }

        buffer.add("");  // ХЗ что это
        buffer.add(Stages.Complete.rawValue);
        buffer.add(self.compression.rawValue);
        buffer.add(sql);

        // Send empty block as marker of end of data
        try ClickHouseBlock().addToBuffer(buffer: buffer, revision: self.serverInfo!.revision);

        try socket.write(from: buffer.toData());
    }

    public func insert(table : String, block : ClickHouseBlock) throws {
        try self.sendQuery(sql : "INSERT INTO \(table) VALUES");

        let _ = try receivePacket(breakOnData : true);

        let buffer = ByteBuffer();
        try block.addToBuffer(buffer: buffer, revision: self.serverInfo!.revision);
        try ClickHouseBlock().addToBuffer(buffer: buffer, revision: self.serverInfo!.revision);

        try socket.write(from: buffer.toData());
        let _ = try receivePacket();
    }

    func receivePacket(breakOnData : Bool = false) throws -> ClickHouseResult? {
        guard let socketReader = try read(socket: socket) else {
            return nil;
        }

        let block  = Block();
        let result = ClickHouseResult(block : block);

        while(true) {
            guard let code = socketReader.read() else {
                print("Unknown code");
                throw ClickHouseError.Unknown;
            }

            guard let scode = ServerCodes(rawValue: code) else {
                print("Unknown code");
                throw ClickHouseError.Unknown;
            }

            switch (scode) {
                case .Data:
                    if (!(try receiveData(socketReader: socketReader, block : block))) {
                        print("can't read data packet from input stream");
                        throw ClickHouseError.Unknown;
                    }

                    if (breakOnData) {
                        return nil;
                    }

                case .Progress :
                    let _ = ClickHouseProgress(socketReader : socketReader, revision : self.serverInfo!.revision);

                case .Exception :
                    try parseException(socketReader: socketReader);

                case .ProfileInfo :
                    let _ = BlockProfile(socketReader: socketReader);

                case .EndOfStream :
                    return result;

                default:
                    return nil;
            }
        }
    }

    func receiveData(socketReader : SocketReader, block : Block) throws -> Bool {
        if (self.compression == CompressionState.Enable) {
            throw ClickHouseError.NotImplemented(message: "Compression not implemented");
        }

        if (self.serverInfo!.revision >= Connection.DBMS_MIN_REVISION_WITH_TEMPORARY_TABLES) {
            guard let _ = socketReader.readString() else {
                return false;
            }
        }

        return block.load(socketReader: socketReader, revision : self.serverInfo!.revision);
    }


    public func close() {
        if (self.socket.isConnected) {
            self.socket.close()
        }
    }

    private func generateQueryId() -> String {
        self.queryCounter += 1;
        return "\(self.queryCounter)";
    }

    private func read(socket: Socket) throws -> SocketReader? {
        if let socketReader = SocketReader(socket: socket) {
            return socketReader;
        }

        return nil;
    }
}

