import Foundation

public struct ClickHouseValue : CustomStringConvertible {
    public let val_number : NSNumber?;
    public let val_string : String?;
    public let val_date   : Date?;
    public let val_array  : [ClickHouseValue]?;
    public let type        : ClickHouseType;

    public init(type : ClickHouseType, number : NSNumber) {
        self.type       = type;
        self.val_number = number;
        self.val_string = nil;
        self.val_date   = nil;
        self.val_array  = nil;
    }

    public init(type : ClickHouseType, string : String) {
        self.type       = type;
        self.val_number = nil;
        self.val_string = string;
        self.val_date   = nil;
        self.val_array  = nil;
    }

    public init(type : ClickHouseType, date : Date) {
        self.type       = type;
        self.val_number = nil;
        self.val_string = nil;
        self.val_date   = date;
        self.val_array  = nil;
    }

    public init(type : ClickHouseType, array : [ClickHouseValue]) {
        self.type       = type;
        self.val_number = nil;
        self.val_string = nil;
        self.val_date   = nil;
        self.val_array  = array;
    }

    public var int8 : Int8? {
        switch (self.type) {
            case .Int8 :
                return self.val_number?.int8Value;
            
            default :
                return nil;
        }
    }

    public var uint8 : UInt8? {
        switch (self.type) {
            case .UInt8 :
                return self.val_number?.uint8Value;
    
            default :
                return nil;
        }
    }

    public var uint16 : UInt16? {
        switch (self.type) {
            case .UInt8, .UInt16 :
                return self.val_number?.uint16Value;
    
            default :
                return nil;
        }
    }

    public var int16 : Int16? {
        switch (self.type) {
            case .Int8, .Int16 :
                return self.val_number?.int16Value;
    
            default :
                return nil;
        }
    }

    public var uint32 : UInt32? {
        switch (self.type) {
            case .UInt8, .UInt16, .UInt32 :
                return self.val_number?.uint32Value;
    
            default :
                return nil;
        }
    }

    public var int32 : Int32? {
        switch (self.type) {
            case .Int8, .Int16, .Int32 :
                return self.val_number?.int32Value;
    
            default :
                return nil;
        }
    }

    public var uint64 : UInt64? {
        switch (self.type) {
            case .UInt8, .UInt16, .UInt32, .UInt64 :
                return self.val_number?.uint64Value;
    
            default :
                return nil;
        }
    }

    public var int64 : Int64? {
        switch (self.type) {
            case .Int8, .Int16, .Int32, .Int64 :
                return self.val_number?.int64Value;
    
            default :
                return nil;
        }
    }

    public var float : Float? {
        switch (self.type) {
            case .Float32 :
                return self.val_number?.floatValue;

        default :
            return nil;
        }
    }

    public var double : Double? {
        switch (self.type) {
            case .Float64 :
                return self.val_number?.doubleValue;

            default :
                return nil;
        }
    }

    public var float32 : Float? {
        return self.float;
    }

    public var float64 : Double? {
        return self.double;
    }

    public var uint : UInt64? {
        return self.uint64;
    }

    public var int : Int64? {
        return self.int64;
    }

    public var date : Date? {
        return self.val_date;
    }

    public var datetime : Date? {
        return self.val_date;
    }

    public var enum8 : String {
        return self.string;
    }

    public var enum16 : String {
        return self.string;
    }

    public var string : String {
        switch (self.type) {
            case .String, .FixedString :
                return self.val_string!;

            case .Int8, .Int16, .Int32, .Int64, .UInt8, .UInt16, .UInt32, .UInt64, .Float32, .Float64 :
                return "\(self.val_number!)";

            case let .Enum8(variants) :
                let v : Int16 = self.val_number!.int16Value;
                return variants[v] ?? "Unknown enum";

            case let .Enum16(variants) :
                let v : Int16 = self.val_number!.int16Value;
                return variants[v] ?? "Unknown enum";

            case .Date :
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.init(identifier: "en_GB")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return dateFormatter.string(from: self.val_date!);

            case .DateTime :
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.init(identifier: "en_GB")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return dateFormatter.string(from: self.val_date!);

            case .Array :
                var list = [String]();
                for l in self.val_array! {
                    list.append(l.description);
                }
                return list.joined(separator: ", ");

            default :
                return "Unknown";
        }
    }

    public var description : String {
        switch (self.type) {
            case .String, .FixedString, .Enum8, .Enum16, .Date, .DateTime :
                return "'\(self.string)'";

            case .Int8, .Int16, .Int32, .Int64, .UInt8, .UInt16, .UInt32, .UInt64, .Float32, .Float64 :
                return self.string;

            case .Array :
                return "[\(self.string)]"

            default :
                return "Unknown";
        }
    }
}