public enum ClickHouseError: Error {
    case Unknown;
    case SocketError;
    case NotConnected;
    case AlreadyConnected;
    case WrongRowsCount;
    case NotImplemented(message : String);
    case Error(code : UInt32, display_text : String, exception : ClickHouseException);
}
