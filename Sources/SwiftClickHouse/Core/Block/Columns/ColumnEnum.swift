import Foundation

class ColumnEnum {
    static func load(num_rows : UInt64, type : ClickHouseType, socketReader : SocketReader, nullable: Bool = false) -> [ClickHouseValue]? {
        var list = [ClickHouseValue]();

        for _ in 0..<num_rows {
            switch (type) {
                case .Enum8 :
                    if let s = socketReader.readByte() {
                        list.append(ClickHouseValue(type : type, number : NSNumber(value : s) ));
                    }

                case .Enum16 :
                    if let s : Int16 = socketReader.readInt() {
                        list.append(ClickHouseValue(type : type, number : NSNumber(value : s) ));
                    }

                default :
                    return nil;
            }
        }

        return list;
    }
}