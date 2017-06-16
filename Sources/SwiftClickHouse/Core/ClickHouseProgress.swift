import Foundation

class ClickHouseProgress {
    let new_rows       : UInt64;
    let new_bytes      : UInt64;
    let new_total_rows : UInt64;

    init(socketReader : SocketReader, revision : UInt64) {
        self.new_rows = socketReader.read()!;
        self.new_bytes = socketReader.read()!;

        if (revision >= Connection.DBMS_MIN_REVISION_WITH_TOTAL_ROWS_IN_PROGRESS) {
            self.new_total_rows = socketReader.read()!;
        } else {
            self.new_total_rows = 0;
        }
    }
}
