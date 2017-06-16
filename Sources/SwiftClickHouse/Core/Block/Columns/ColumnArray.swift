import Foundation

class ColumnArray {
    static func load(num_rows : UInt64, type : ClickHouseType, socketReader : SocketReader) -> [ClickHouseValue]? {
        let in_array_code : ClickHouseType;
        switch (type) {
            case let .Array(in_array) :
                in_array_code = in_array;

            default :
                return nil;
        }

        if let size : UInt64 = socketReader.readInt() {
            var list = [ClickHouseValue]();

            for _ in 0..<num_rows {
                if (size > 0) {
                    if let values = Block.loadColumnByType(num_rows: size, code: in_array_code, socketReader: socketReader) {
                        list.append(ClickHouseValue(type : type, array : values));
                    } else {
                        return nil;
                    }
                }
            }

            return list;
        }

        return nil;
    }

    static func save (buffer : ByteBuffer, type : ClickHouseType, row : ClickHouseValue) {
        let in_array_code : ClickHouseType;
            switch (type) {
                case let .Array(in_array) :
                    in_array_code = in_array;

                default :
                    return;
        }

        let size = UInt64(row.val_array!.count);
        buffer.add(size);

        ClickHouseBlock.saveColumn(buffer: buffer, type: in_array_code, column: row.val_array!);
    }
}