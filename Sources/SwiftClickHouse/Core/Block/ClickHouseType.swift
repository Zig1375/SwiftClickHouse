import Foundation

public enum ClickHouseType {
    case Void;
    case Int8;
    case Int16;
    case Int32;
    case Int64;
    case UInt8;
    case UInt16;
    case UInt32;
    case UInt64;
    case Float32;
    case Float64;
    case Enum8([Int16 : String]);
    case Enum16([Int16 : String]);
    case String;
    case FixedString(Int);
    case DateTime;
    case Date;
    indirect case Array(ClickHouseType);
    indirect case Nullable(ClickHouseType);
    indirect case Tuple([ClickHouseType]);

    func getName() -> String {
        switch (self) {
            case .Void:
                return "Void";
            case .Int8:
                return "Int8";
            case .Int16:
                return "Int16";
            case .Int32:
                return "Int32";
            case .Int64:
                return "Int64";
            case .UInt8:
                return "UInt8";
            case .UInt16:
                return "UInt16";
            case .UInt32:
                return "UInt32";
            case .UInt64:
                return "UInt64";
            case .Float32:
                return "Float32";
            case .Float64:
                return "Float64";
            case let .Enum8(variants) :
                var list : [String] = [];
                for (key, val) in variants {
                    list.append("'\(key)' = \(val)");
                }
                return "Enum8(\(list.joined(separator: ", ")))";
            case let .Enum16(variants) :
                var list : [String] = [];
                for (key, val) in variants {
                    list.append("'\(key)' = \(val)");
                }
                return "Enum16(\(list.joined(separator: ", ")))";
            case .String:
                return "String";
            case let .FixedString(string_size):
                return "FixedString(\(string_size))";
            case .DateTime:
                return "DateTime";
            case .Date:
                return "Date";
            case let .Array(item_type):
                return "Array(\(item_type.getName()))";
            case let .Nullable(item_type):
                return "Nullable(\(item_type.getName()))";
            case let .Tuple(item_types):
                var list : [String] = [];
                for type in item_types {
                    list.append(type.getName());
                }
                return "Tuple(\(list.joined(separator: ", ")))";
            }
    }
}

