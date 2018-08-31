[![Build Status](https://travis-ci.org/Zig1375/SwiftClickHouse.svg?branch=master)](https://travis-ci.org/Zig1375/SwiftClickHouse)

## Introduction

ClickHouse Swift client library.

## Here is an example on how to use it:

### Connection

```swift
import SwiftClickHouse;

do {
    // let conn = try Connection(); /// Will use defaults values
    let conn = try Connection(host : "localhost", port : 9000, database : "default", user : "default", password : "", compression : .Disable);
    

    // YOUR CODE HERE
}  catch ClickHouseError.Error(let code, let display_text, let exception) {
    print("\(errno) : \(error)");
} catch {
    print("Unknown error");
}
```


### Query

```swift
if let result = try? connect.query(sql: "select * from test") {
    let row = result!.fetchRow()!;
    print(row["a"]!.double)
    print(result!.description);
}
```


### Insert

```swift
let block = ClickHouseBlock();
block.append(name: "a", 100.500);

if let _ = try? connect.insert(table: "test", block: block) {
    // Success
}
```



#### Attention

Compression not implemented now.