import Foundation

class ColumnNumber {
    static func load(num_rows : UInt64, type : ClickHouseType, socketReader : SocketReader, nullable: Bool = false) -> [ClickHouseValue]? {
        var add : ((SocketReader) -> NSNumber?);

        switch (type) {
            case .UInt8 :
                add = ColumnNumber.addUInt8;
                break;

            case .Int8 :
                add = ColumnNumber.addInt8;
                break;

            case .UInt16 :
                add = ColumnNumber.addUInt16;
                break;

            case .Int16 :
                add = ColumnNumber.addInt16;
                break;

            case .UInt32 :
                add = ColumnNumber.addUInt32;
                break;

            case .Int32 :
                add = ColumnNumber.addInt32;
                break;

            case .UInt64 :
                add = ColumnNumber.addUInt64;
                break;

            case .Int64 :
                add = ColumnNumber.addInt64;
                break;

            case .Float32 :
                add = ColumnNumber.addFloat
                break;

            case .Float64 :
                add = ColumnNumber.addDouble;
                break;

            default :
                return nil;
        }

        var list = [ClickHouseValue]();
        for _ in 0..<num_rows {
            var isNull = false;
            if ((nullable) && (ColumnNumber.isNull(socketReader: socketReader))) {
                list.append(ClickHouseValue(type : type));
                isNull = true;
            }

            if let t = add(socketReader) {
                if (!isNull) {
                    list.append(ClickHouseValue(type: type, number: t));
                }
            } else {
                return nil;
            }
        }

        return list;
    }

    private static func isNull(socketReader: SocketReader) -> Bool {
        if let t : UInt8 = socketReader.readInt() {
            return t == 1;
        }

        return false;
    }

    private static func addUInt8(socketReader : SocketReader) -> NSNumber? {
        if let t : UInt8 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addInt8(socketReader : SocketReader) -> NSNumber? {
        if let t : Int8 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addUInt16(socketReader : SocketReader) -> NSNumber? {
        if let t : UInt16 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addInt16(socketReader : SocketReader) -> NSNumber? {
        if let t : Int16 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addUInt32(socketReader : SocketReader) -> NSNumber? {
        if let t : UInt32 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addInt32(socketReader : SocketReader) -> NSNumber? {
        if let t : Int32 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addUInt64(socketReader : SocketReader) -> NSNumber? {
        if let t : UInt64 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addInt64(socketReader : SocketReader) -> NSNumber? {
        if let t : Int64 = socketReader.readInt() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addFloat(socketReader : SocketReader) -> NSNumber? {
        if let t : Float = socketReader.readFloat() {
            return NSNumber(value : t);
        }

        return nil;
    }

    private static func addDouble(socketReader : SocketReader) -> NSNumber? {
        if let t : Double = socketReader.readDouble() {
            return NSNumber(value : t);
        }

        return nil;
    }
}