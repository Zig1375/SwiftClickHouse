import Foundation

class ByteBuffer {
    var data: [UInt8];

    init() {
        self.data = [UInt8]()
    }

    init(_ existingBytes: [UInt8]) {
        self.data = existingBytes
    }

    func add(_ frm : ClientCodes) {
        self.add(frm.rawValue);
    }

    func addFixed(_ frm: UInt8) {
        self.copyBytes(value : frm, length : 1);
    }

    func addFixed(_ frm: Int8) {
        self.copyBytes(value : frm, length : 1);
    }

    func addFixed(_ frm: UInt16) {
        self.copyBytes(value : frm, length : 2);
    }

    func addFixed(_ frm: Int16) {
        self.copyBytes(value : frm, length : 2);
    }

    func addFixed(_ frm: Int32) {
        self.copyBytes(value : frm, length : 4);
    }

    func addFixed(_ frm: UInt32) {
        self.copyBytes(value : frm, length : 4);
    }

    func addFixed(_ frm: Int64) {
        self.copyBytes(value : frm, length : 8);
    }

    func addFixed(_ frm: UInt64) {
        self.copyBytes(value : frm, length : 8);
    }

    func addFixed(_ frm: Float) {
        self.copyBytes(value : frm, length : 4);
    }

    func addFixed(_ frm: Double) {
        self.copyBytes(value : frm, length : 8);
    }

    func copyBytes<T>(value:T, length : Int) {
        var localValue = value;
        var intBytes:Array<UInt8> = Array<UInt8>(repeating:0, count:length);
        memcpy(&intBytes, &localValue, Int(length));

        self.data += intBytes;
    }

    func add(_ frm: UInt64) {
        var value = frm;
        var byte : UInt8 = 0;
        for _ in 0...8 {
            byte = UInt8(value & 0x7F);
            if (value > 0x7F) {
                byte |= 0x80;
            }

            self.data.append(byte);
            value >>= 7;
            if (value == 0) {
                break;
            }
        }
    }

    func add(_ frm : String) {
        let len = frm.utf8.count;
        self.add(UInt64(len));

        if (len > 0) {
            self.data += Array(frm.utf8);
        }
    }

    func toData() -> Data {
        return Data(bytes : self.data);
    }
}
