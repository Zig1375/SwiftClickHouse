import Foundation

public class ClickHouseBlock {
    let is_overflows : UInt8;
    let bucket_num   : Int32;
    var columns       : [String : [ClickHouseValue]] = [:];

    public init(is_overflows : UInt8 = 0, bucket_num : Int32 = -1) {
        self.is_overflows = is_overflows;
        self.bucket_num   = bucket_num;
    }
    
    public func append(name : String, value : ClickHouseValue) {
        if (self.columns[name] == nil) {
            self.columns[name] = [];
        }

        self.columns[name]!.append(value);
    }

    // UInt8
    public func append(name : String, value : UInt8) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ UInt8 ]) {
        for val in value {
            let t = ClickHouseValue(type : .UInt8, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }

    // Int8
    public func append(name : String, value : Int8) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ Int8 ]) {
        for val in value {
            let t = ClickHouseValue(type : .Int8, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }


    // UInt16
    public func append(name : String, value : UInt16) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ UInt16 ]) {
        for val in value {
            let t = ClickHouseValue(type : .UInt16, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }

    // Int16
    public func append(name : String, value : Int16) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ Int16 ]) {
        for val in value {
            let t = ClickHouseValue(type : .Int16, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }

    
    // UInt32
    public func append(name : String, value : UInt32) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ UInt32 ]) {
        for val in value {
            let t = ClickHouseValue(type : .UInt32, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }

    // Int32
    public func append(name : String, value : Int32) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ Int32 ]) {
        for val in value {
            let t = ClickHouseValue(type : .Int32, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }
    

    
    // UInt64
    public func append(name : String, value : UInt64) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ UInt64 ]) {
        for val in value {
            let t = ClickHouseValue(type : .UInt64, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }

    // Int64
    public func append(name : String, value : Int64) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ Int64 ]) {
        for val in value {
            let t = ClickHouseValue(type : .Int64, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }

    // Int
    public func append(name : String, value : Int) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ Int ]) {
        for val in value {
            let t = ClickHouseValue(type : .Int64, number : NSNumber(value : val));
            self.append(name: name, value: t);
        }
    }

    // String
    public func append(name : String, value : String) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ String ]) {
        for val in value {
            let t = ClickHouseValue(type : .String, string: val);
            self.append(name: name, value: t);
        }
    }


    // Date
    public func append(name : String, value : Date) {
        self.append(name: name, value: [value]);
    }

    public func append(name : String, value : [ Date ]) {
        for val in value {
            let t = ClickHouseValue(type : .Date, date : val);
            self.append(name: name, value: t);
        }
    }


    func addToBuffer(buffer : ByteBuffer, revision : UInt64) throws {
        // Считаем кол-во строк
        let rows = (self.columns.count > 0) ? self.columns.first!.value.count : 0;

        for (_, column) in self.columns {
            if (rows != column.count) {
                throw ClickHouseError.WrongRowsCount;
            }
        }

        buffer.add(ClientCodes.Data.rawValue);

        if (revision >= Connection.DBMS_MIN_REVISION_WITH_TEMPORARY_TABLES) {
            buffer.add("");
        }

        if (revision >= Connection.DBMS_MIN_REVISION_WITH_BLOCK_INFO) {
            buffer.add(UInt64(1));
            buffer.addFixed(self.is_overflows);
            buffer.add(UInt64(2));
            buffer.addFixed(self.bucket_num);
            buffer.add(UInt64(0));
        }

        buffer.add(UInt64(self.columns.count));
        buffer.add(UInt64(rows));

        for (name, column) in self.columns {
            let type = column.first!.type;
            buffer.add(name);
            buffer.add(type.getName());

            ClickHouseBlock.saveColumn(buffer: buffer, type: type, column: column);
        }
    }

    static func saveColumn(buffer : ByteBuffer, type : ClickHouseType, column : [ClickHouseValue]) {
        for row in column {
            switch (type) {
                case .Int8    : buffer.addFixed(row.int8!);
                case .Int16   : buffer.addFixed(row.int16!);
                case .Int32   : buffer.addFixed(row.int32!);
                case .Int64   : buffer.addFixed(row.int64!);

                case .UInt8   : buffer.addFixed(row.uint8!);
                case .UInt16  : buffer.addFixed(row.uint16!);
                case .UInt32  : buffer.addFixed(row.uint32!);
                case .UInt64  : buffer.addFixed(row.uint64!);

                case .Float32 : buffer.addFixed(row.float!);
                case .Float64 : buffer.addFixed(row.double!);

                case .Enum8   : buffer.add(row.string);
                case .Enum16  : buffer.add(row.string);

                case .String      : buffer.add(row.string);
                case .FixedString : buffer.add(row.string);

                case .Date     : buffer.addFixed(UInt16(row.date!.timeIntervalSince1970 / 86400));
                case .DateTime : buffer.addFixed(UInt32(row.date!.timeIntervalSince1970));

                case .Array    : ColumnArray.save(buffer : buffer, type : type, row : row);

                default :
                    break;
            }
        }
    }
}
