import Foundation

class BlockProfile {
    let rows   : UInt64;
    let blocks : UInt64;
    let bytes  : UInt64;

    let applied_limit                : Bool;
    let rows_before_limit            : UInt64;
    let calculated_rows_before_limit : Bool;

    init(socketReader : SocketReader) {
        self.rows   = socketReader.read()!;
        self.blocks = socketReader.read()!;
        self.bytes  = socketReader.read()!;

        self.applied_limit                = (socketReader.readByte()! == 1);
        self.rows_before_limit            = socketReader.read()!;
        self.calculated_rows_before_limit = (socketReader.readByte()! == 1);
    }
}
