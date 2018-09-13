import Foundation

class Block {
    var is_overflows : UInt8 = 0;
    var bucket_num : Int32 = -1;
    var rows : UInt64 = 0;
    var columns       : [String : [ClickHouseValue]] = [:];
    var columns_order : [String] = [];
    var currentRow : UInt64 = 0;

    public init() {

    }

    func load(socketReader : SocketReader, revision : UInt64) -> Bool {
        if (revision >= Connection.DBMS_MIN_REVISION_WITH_BLOCK_INFO) {
            guard let _ = socketReader.read() else {
                return false;
            }

            if let is_overflows = socketReader.readByte() {
                self.is_overflows = is_overflows;
            } else {
                return false;
            }

            guard let _ = socketReader.read() else {
                return false;
            }

            if let bucket_num : Int32 = socketReader.readInt() {
                self.bucket_num = bucket_num;
            } else {
                return false;
            }

            guard let _ = socketReader.read() else {
                return false;
            }
        }

        guard let num_columns = socketReader.read() else {
            return false;
        }

        guard let num_rows = socketReader.read() else {
            return false;
        }

        self.rows += num_rows;

        for _ in 0..<num_columns {
            guard let name = socketReader.readString() else {
                return false;
            }

            guard let type = socketReader.readString() else {
                return false;
            }

            if (self.columns[name] == nil) {
                self.columns[name] = [];
                self.columns_order.append(name);
            }

            if (num_rows > 0) {
                if let value = self.loadColumnByType(num_rows: num_rows, type: type, socketReader : socketReader) {
                    self.columns[name] = self.columns[name]! + value;
                } else {
                    print("Unknown type: \(type)")
                }
            }
        }

        return true;
    }

    func loadColumnByType(num_rows : UInt64, type : String, socketReader : SocketReader) -> [ClickHouseValue]? {
        guard let code = self.getTypeCode(type: type) else {
            return nil;
        }

        return Block.loadColumnByType(num_rows : num_rows, code : code, socketReader : socketReader);
    }

    static func loadColumnByType(num_rows : UInt64, code : ClickHouseType, socketReader : SocketReader, nullable: Bool = false) -> [ClickHouseValue]? {
        switch (code) {
            case .UInt8, .UInt16, .UInt32, .UInt64, .Int8, .Int16, .Int32, .Int64, .Float32, .Float64 :
                return ColumnNumber.load(num_rows : num_rows, type : code, socketReader : socketReader, nullable: nullable);

            case .Date, .DateTime :
                return ColumnDate.load(num_rows : num_rows, type : code, socketReader : socketReader, nullable: nullable);

            case .String, .FixedString :
                return ColumnString.load(num_rows : num_rows, type : code, socketReader : socketReader, nullable: nullable);

            case .Array :
                return ColumnArray.load(num_rows : num_rows, type : code, socketReader : socketReader, nullable: nullable);

            case .Enum8, .Enum16 :
                return ColumnEnum.load(num_rows : num_rows, type : code, socketReader : socketReader, nullable: nullable);

            case let .Nullable(in_type):
                return Block.loadColumnByType(num_rows : num_rows, code : in_type, socketReader : socketReader, nullable: true);

            default :
                return nil;
        }
    }

    func getTypeCode(type : String) -> ClickHouseType? {
        let t : String;
        if (type.hasPrefix("FixedString")) {
            t = "FixedString";
        } else if (type.hasPrefix("Array")) {
            t = "Array";
        } else if (type.hasPrefix("Enum8")) {
            t = "Enum8";
        } else if (type.hasPrefix("Enum16")) {
            t = "Enum16";
        } else if (type.hasPrefix("Nullable")) {
            t = "Nullable";
        } else {
            t = type;
        }

        switch (t) {
            case "UInt8" :
                return ClickHouseType.UInt8;

            case "Int8" :
                return ClickHouseType.Int8;

            case "UInt16" :
                return ClickHouseType.UInt16;

            case "Int16" :
                return ClickHouseType.Int16;

            case "UInt32" :
                return ClickHouseType.UInt32;

            case "Int32" :
                return ClickHouseType.Int32;

            case "UInt64" :
                return ClickHouseType.UInt64;

            case "Int64" :
                return ClickHouseType.Int64;

            case "Float32" :
                return ClickHouseType.Float32;

            case "Float64" :
                return ClickHouseType.Float64;

            case "Date" :
                return ClickHouseType.Date;

            case "DateTime" :
                return ClickHouseType.DateTime;

            case "String" :
                return ClickHouseType.String;

            case "FixedString" :
                let tn = type.components(separatedBy: "(")[1];
                let n : Int = Int(tn.components(separatedBy: ")")[0])!;
                return ClickHouseType.FixedString(n);

            case "Enum8" :
                return ClickHouseType.Enum8(self.parseEnum(type: type));

            case "Enum16" :
                return ClickHouseType.Enum16(self.parseEnum(type: type));

            case "Array" :
                let tn = type.components(separatedBy: "(")[1];
                let n  = tn.components(separatedBy: ")")[0];

                if let temp = self.getTypeCode(type : n) {
                    return ClickHouseType.Array(temp);
                }
                return nil;

            case "Nullable" :
                let tn = type.components(separatedBy: "(")[1];
                let n  = tn.components(separatedBy: ")")[0];

                if let temp = self.getTypeCode(type : n) {
                    return ClickHouseType.Nullable(temp);
                }
                return nil;

            default :
                return nil;
        }
    }

    private func parseEnum(type : String) -> [Int16 : String] {
        var result = [Int16 : String]();
        let temp = type.components(separatedBy: ", ");
        for t in temp {
            let m = t.match(pattern: "'(.*?)' = (\\d+)");
            result[ Int16(m[1])! ] = m[0];
        }

        return result;
    }
}
