//
//  LoggingInterceptor.swift
//  CodeServices
//
//  Created by Dima Bart.
//  Copyright © 2021 Code Inc. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf

class LoggingInterceptor<Request, Response>: ClientInterceptor<Request, Response> {
    
    private let expanded: Bool = false
    
    override func send(_ part: GRPCClientRequestPart<Request>, promise: EventLoopPromise<Void>?, context: ClientInterceptorContext<Request, Response>) {
        switch part {
        case .metadata(let headers):
//            print("gRPC Sent Metadata: \(headers)")
            break
        case .message(let message, _):
            if expanded {
                let modifiedMessage = String(describing: message).components(separatedBy: "\n").map { "| \($0)"}.joined(separator: "\n")
                print("\n| ------------------------------------------------------\n| \(Date.timestamp) gRPC ➡️: \(modifiedMessage)------------------------------------------------------")
            } else {
                if let typed = message as? SwiftProtobuf.Message {
                    let name = type(of: typed).protoMessageName.components(separatedBy: ".").last ?? "Unknown"
                    print("\(Date.timestamp) gRPC ➡️: \(name)")
                }
            }
            break
            
        default:
            break
        }
        
        context.send(part, promise: promise)
    }
    
    override func receive(_ part: GRPCClientResponsePart<Response>, context: ClientInterceptorContext<Request, Response>) {
        switch part {
        case .metadata(let headers):
//            print("gRPC Received Metadata: \(headers)")
            break
        case .message(let message):
            if expanded {
                let modifiedMessage = String(describing: message).components(separatedBy: "\n").map { "| \($0)"}.joined(separator: "\n")
                print("\n| ------------------------------------------------------\n| \(Date.timestamp) gRPC ✅: \(modifiedMessage)------------------------------------------------------")
            } else {
                if let typed = message as? SwiftProtobuf.Message {
                    let name = type(of: typed).protoMessageName.components(separatedBy: ".").last ?? "Unknown"
                    print("\(Date.timestamp) gRPC ✅: \(name)")
                }
            }
            break
            
        default:
            break
        }
        
        context.receive(part)
    }
}

private extension Date {
    
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "(hh:mm:ss.SSSS)"
        return f
    }()
    
    static var timestamp: String {
        formatter.string(from: Date())
    }
}
