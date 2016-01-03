//
//  Json.swift
//  JsonSerializer
//
//  Created by Fuji Goro on 2014/09/15.
//  Copyright (c) 2014 Fuji Goro. All rights reserved.
//

public enum Json: CustomStringConvertible, CustomDebugStringConvertible, Equatable {
    
    case NullValue
    case BooleanValue(Bool)
    case NumberValue(Double)
    case StringValue(String)
    case ArrayValue([Json])
    case ObjectValue([String:Json])

    // MARK: Initialization
    
    init(_ value: Bool) {
        self = .BooleanValue(value)
    }
    
    init(_ value: Double) {
        self = .NumberValue(value)
    }
    
    init(_ value: String) {
        self = .StringValue(value)
    }
    
    init(_ value: [Json]) {
        self = .ArrayValue(value)
    }
    
    init(_ value: [String : Json]) {
        self = .ObjectValue(value)
    }
    
    // MARK: From
    
    static func from(value: Bool) -> Json {
        return .BooleanValue(value)
    }

    static func from(value: Double) -> Json {
        return .NumberValue(value)
    }

    static func from(value: String) -> Json {
        return .StringValue(value)
    }

    static func from(value: [Json]) -> Json {
        return .ArrayValue(value)
    }

    static func from(value: [String : Json]) -> Json {
        return .ObjectValue(value)
    }
}

// MARK: Serialization

extension Json {
    public static func deserialize(source: String) throws -> Json {
        return try JsonDeserializer(source.utf8).deserialize()
    }
    
    public static func deserialize(source: [UInt8]) throws -> Json {
        return try JsonDeserializer(source).deserialize()
    }
    
    public static func deserialize<ByteSequence: CollectionType where ByteSequence.Generator.Element == UInt8>(sequence: ByteSequence) throws -> Json {
        return try JsonDeserializer(sequence).deserialize()
    }
}

extension Json {
    public enum SerializationStyle {
        case Default
        case PrettyPrint
        
        private var serializer: JsonSerializer.Type {
            switch self {
            case .Default:
                return DefaultJsonSerializer.self
            case .PrettyPrint:
                return PrettyJsonSerializer.self
            }
        }
    }
    
    public func serialize(style: SerializationStyle = .Default) -> String {
        return style.serializer.init().serialize(self)
    }
}

// MARK: Convenience

extension Json {
    public var isNull: Bool {
        guard case .NullValue = self else { return false }
        return true
    }
    
    public var boolValue: Bool? {
        guard case let .BooleanValue(bool) = self else {
            return nil
        }
        
        return bool
    }

    public var doubleValue: Double? {
        guard case let .NumberValue(double) = self else {
            return nil
        }
        
        return double
    }

    public var intValue: Int? {
        guard case let .NumberValue(double) = self where double == Double(Int(double)) else {
            return nil
        }
        
        return Int(double)
    }

    public var uintValue: UInt? {
        guard let intValue = intValue else { return nil }
        return UInt(intValue)
    }

    public var stringValue: String? {
        guard case let .StringValue(string) = self else {
            return nil
        }
        
        return string
    }

    public var arrayValue: [Json]? {
        guard case let .ArrayValue(array) = self else { return nil }
        return array
    }

    public var objectValue: [String : Json]? {
        guard case let .ObjectValue(object) = self else { return nil }
        return object
    }
}

extension Json {
    public subscript(index: Int) -> Json? {
        assert(index > 0)
        guard let array = arrayValue where index < array.count else { return nil }
        return array[index]
    }

    public subscript(key: String) -> Json? {
        guard let dict = objectValue else { return nil }
        return dict[key]
    }
}

extension Json {
    public var description: String {
        return serialize(DefaultJsonSerializer())
    }

    public var debugDescription: String {
        return serialize(PrettyJsonSerializer())
    }
}

extension Json {
    public func serialize(serializer: JsonSerializer) -> String {
        return serializer.serialize(self)
    }
}


public func ==(lhs: Json, rhs: Json) -> Bool {
    switch lhs {
    case .NullValue:
        return rhs.isNull
    case .BooleanValue(let lhsValue):
        guard let rhsValue = rhs.boolValue else { return false }
        return lhsValue == rhsValue
    case .StringValue(let lhsValue):
        guard let rhsValue = rhs.stringValue else { return false }
        return lhsValue == rhsValue
    case .NumberValue(let lhsValue):
        guard let rhsValue = rhs.doubleValue else { return false }
        return lhsValue == rhsValue
    case .ArrayValue(let lhsValue):
        guard let rhsValue = rhs.arrayValue else { return false }
        return lhsValue == rhsValue
    case .ObjectValue(let lhsValue):
        guard let rhsValue = rhs.objectValue else { return false }
        return lhsValue == rhsValue
    }
}

// MARK: Literal Convertibles

extension Json: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .NullValue
    }
}

extension Json: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .BooleanValue(value)
    }
}

extension Json: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .NumberValue(Double(value))
    }
}

extension Json: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .NumberValue(Double(value))
    }
}

extension Json: StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .StringValue(value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType) {
        self = .StringValue(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .StringValue(value)
    }
}

extension Json: ArrayLiteralConvertible {
    public init(arrayLiteral elements: Json...) {
        self = .ArrayValue(elements)
    }
}

extension Json: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, Json)...) {
        var object = [String : Json](minimumCapacity: elements.count)
        elements.forEach { key, value in
            object[key] = value
        }
        self = .ObjectValue(object)
    }
}
