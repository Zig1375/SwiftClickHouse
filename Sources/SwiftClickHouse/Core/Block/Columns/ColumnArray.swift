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

        // Получаем смещения
        var offsets = [UInt64]();
        var prev_offset : UInt64 = 0;
        for _ in 0..<num_rows {
            if let offset : UInt64 = socketReader.readInt() {
                offsets.append(offset - prev_offset);
                prev_offset = offset;
            }
        }

        var list = [ClickHouseValue]();
        for i in 0..<num_rows {
            if let values = Block.loadColumnByType(num_rows: offsets[Int(i)], code: in_array_code, socketReader: socketReader) {
                list.append(ClickHouseValue(type : type, array : values));
            } else {
                return nil;
            }
        }

        return list;
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