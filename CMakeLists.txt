cmake_minimum_required(VERSION 3.7)
project(SwiftClickHouse)

add_custom_target(SwiftClickHouse ALL
        COMMAND /Library/Developer/Toolchains/swift-4.0.3-RELEASE.xctoolchain/usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES Sources Package.swift)
