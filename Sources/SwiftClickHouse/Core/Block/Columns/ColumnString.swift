import Foundation

class ColumnString {
    static func load(num_rows : UInt64, type : ClickHouseType, socketReader : SocketReader, nullable: Bool = false) -> [ClickHouseValue]? {
        var list = [ClickHouseValue]();

        for _ in 0..<num_rows {
            switch (type) {
                case .String :
                    if let s = socketReader.readString() {
                        list.append(ClickHouseValue(type: type, string : s));
                    }

                case let .FixedString(size) :
                    if let s = socketReader.readFixedString(length : size) {
                        list.append(ClickHouseValue(type: type, string : s));
                    }

                default :
                    return nil;
            }
        }

        return list;
    }
}