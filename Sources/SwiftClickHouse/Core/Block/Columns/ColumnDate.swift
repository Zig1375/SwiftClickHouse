import Foundation

class ColumnDate {
    static func load(num_rows : UInt64, type : ClickHouseType, socketReader : SocketReader) -> [ClickHouseValue]? {
        var list = [ClickHouseValue]();

        for _ in 0..<num_rows {
            switch (type) {
                case .Date :
                    if let d: UInt16 = socketReader.readInt() {
                        list.append( ClickHouseValue( type : type, date : Date(timeIntervalSince1970: TimeInterval(UInt32(d) * 86400)) ) );
                    } else {
                        return nil;
                    }

                case .DateTime :
                    if let d: UInt32 = socketReader.readInt() {
                        list.append( ClickHouseValue( type : type, date : Date(timeIntervalSince1970: TimeInterval(d)) ) );
                    } else {
                        return nil;
                    }

                default :
                    return nil;
            }
        }

        return list;
    }
}