import Foundation

class ColumnNullable {
    static func load(num_rows : UInt64, type : ClickHouseType, socketReader : SocketReader) -> [ClickHouseValue]? {
        // Получаем список значение нулов
        var nulls = [Bool]();
        for _ in 0..<num_rows {
            let t : UInt8 = socketReader.readInt() ?? 1;
            nulls.append(t == 1);
        }

        return Block.loadColumnByType(num_rows: num_rows, code: type, socketReader: socketReader, nulls: nulls);
    }
}