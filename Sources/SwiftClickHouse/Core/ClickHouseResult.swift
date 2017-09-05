import Foundation

public class ClickHouseResult : CustomStringConvertible {
    private let block : Block;
    private var current_row : Int = 0;

    init(block : Block) {
        self.block = block;
    }

    public var rows_count : UInt64 {
        return self.block.rows;
    }

    public func fetchRow(row : Int? =  nil) -> OrderedDictionary<String, ClickHouseValue>? {
        if (row != nil) {
            self.current_row = row!;
        }

        if (self.current_row >= Int(self.block.rows)) {
            return nil;
        }

        var result = OrderedDictionary<String, ClickHouseValue>();
        for name in self.block.columns_order {
            if let val = self.block.columns[name]?[self.current_row] {
                result[name] = val;
            }
        }

        self.current_row += 1;
        return result;
    }

    public var description : String {
        var list = [String]();
        while let row = fetchRow() {
            var row_str = [String]();
            for name in self.block.columns_order {
                row_str.append("'\(name)' = \(row[name]?.description ?? "")");
            }

            list.append(row_str.joined(separator: ", "));
        }

        return list.joined(separator: "\n");
    }
}
