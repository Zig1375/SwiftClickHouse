[![Build Status](https://travis-ci.org/Zig1375/SwiftClickHouse.svg?branch=master)](https://travis-ci.org/Zig1375/SwiftClickHouse)

## Introduction

ClickHouse Swift client library.

Now supported ONLY MacOs

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

#### Attention

Compression not implemented now.