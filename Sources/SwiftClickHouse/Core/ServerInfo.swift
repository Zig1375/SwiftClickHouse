import Foundation

struct ServerInfo {
    let name : String;
    let version_major : UInt64;
    let version_minor : UInt64;
    let revision : UInt64;
    let timezone : String?;

    init(name : String, version_major : UInt64, version_minor : UInt64, revision : UInt64, timezone : String? = nil) {
        self.name = name;
        self.version_major = version_major;
        self.version_minor = version_minor;
        self.revision = revision;
        self.timezone = timezone;
    }
}
