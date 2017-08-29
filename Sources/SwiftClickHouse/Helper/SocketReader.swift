import Foundation
import zSocket


class SocketReader {
    let socket : Socket;
    var data: [UInt8] = [UInt8]();
    var offset = 0;

    init?(socket: Socket) {
        self.socket = socket;
        if (!self.readFromSocket()) {
            return nil;
        }
    }

    func isValid() -> Bool {
        return self.offset < self.data.count;
    }

    func getBytes(length : Int) -> [UInt8] {
        let temp : [UInt8] = Array(self.data[offset..<(offset + length)]);
        offset += length;
        return temp;
    }

    private func readFromSocket() -> Bool {
        var data = Data();
        if let bytesRead = try? socket.read(into: &data) {
            if bytesRead > 0 {
                // print("Read \(bytesRead) from socket...");

                let arr: [UInt8] = data.withUnsafeBytes {
                    [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
                }

                self.data += arr;
                return true;
            }
        }

        return false;
    }

    func checkHasData(length : Int) -> Bool {
        if (self.offset + length > self.data.count) {
            // Мало данных, получаем еще
            return self.readFromSocket();
        }

        return true;
    }

    func readInt() -> Int64? {
        if (self.checkHasData(length : 8)) {
            let intBytes = self.getBytes(length: 8);
            var int : Int64 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readInt() -> UInt64? {
        if (self.checkHasData(length : 8)) {
            let intBytes = self.getBytes(length: 8);
            var int : UInt64 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readInt() -> Int32? {
        if (self.checkHasData(length : 4)) {
            let intBytes = self.getBytes(length: 4);
            var int : Int32 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readInt() -> UInt32? {
        if (self.checkHasData(length : 4)) {
            let intBytes = self.getBytes(length: 4);
            var int : UInt32 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readInt() -> Int16? {
        if (self.checkHasData(length : 2)) {
            let intBytes = self.getBytes(length: 2);
            var int : Int16 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readInt() -> UInt16? {
        if (self.checkHasData(length : 2)) {
            let intBytes = self.getBytes(length: 2);
            var int : UInt16 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readInt() -> Int8? {
        if (self.checkHasData(length : 1)) {
            let intBytes = self.getBytes(length: 1);
            var int : Int8 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readInt() -> UInt8? {
        if (self.checkHasData(length : 1)) {
            let intBytes = self.getBytes(length: 1);
            var int : UInt8 = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }


    func readFloat() -> Float? {
        if (self.checkHasData(length : 4)) {
            let intBytes = self.getBytes(length: 4);
            var int : Float = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readDouble() -> Double? {
        if (self.checkHasData(length : 8)) {
            let intBytes = self.getBytes(length: 8);
            var int : Double = 0;
            memcpy(&int, intBytes, intBytes.count);
            return int;
        }

        return nil;
    }

    func readByte() -> UInt8? {
        if (!self.checkHasData(length : 1)) {
            return nil;
        }

        self.offset += 1;
        return self.data[self.offset - 1];
    }

    func read() -> UInt64? {
        let x80 : UInt8 = 0x80;
        var value : UInt64 = 0;
        for i : UInt8 in 0...8 {
            if let byte = self.readByte() {
                let b1 : UInt64 = UInt64(byte & 0x7F);
                let b2 : UInt64 = UInt64(7 * i);
                value |= b1 << b2;

                if ((byte & x80) == 0) {
                    return value;
                }
            } else {
                return nil;
            }
        }

        return nil;
    }

    func readString() -> String? {
        if let ulen = self.read() {
            if (ulen > 0x00FFFFFF) {
                return nil;
            }

            let len = Int(ulen);
            if (!self.checkHasData(length : len)) {
                return nil;
            }

            if let utf8String = String(data: Data(self.getBytes(length: len)), encoding: .utf8) {
                return utf8String;
            }
        }

        return nil;
    }

    func readFixedString(length : Int) -> String? {
        if (!self.checkHasData(length : length)) {
            return nil;
        }

        if let utf8String = String(data: Data(self.getBytes(length: length)), encoding: .utf8) {
            return utf8String;
        }

        return nil;
    }
}