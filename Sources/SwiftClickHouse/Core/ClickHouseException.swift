import Foundation

public class ClickHouseException: CustomStringConvertible {
    public var code : UInt32 = 0;
    public var name : String = "";
    public var display_text : String = "";
    public var stack_trace : String = "";
    public var nested : ClickHouseException? = nil;

    public var description: String {
        var result = "Code: \(code), \(name) = \(display_text) \n\(stack_trace)";

        if let n = nested {
            result += "\n\n\n" + n.description;
        }

        return result;
    }
}
