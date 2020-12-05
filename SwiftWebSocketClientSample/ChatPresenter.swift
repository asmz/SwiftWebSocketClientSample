//
//  WebSocketClient.swift
//  SwiftWebSocketClientSample
//
//  Created by Akira Shimizu on 2020/12/05.
//

import Foundation

class WebSocketClient: NSObject, ObservableObject {

    private var webSocketTask: URLSessionWebSocketTask?

    @Published var messages: [String] = []

    func initializeSocket() {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession.webSocketTask(with: URL(string: "ws://localhost:5001")!)
    }

    func connect() {
        webSocketTask?.resume()
        receive()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    func send(_ message: String) {
        let msg = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(msg) { error in
            if let error = error {
                print(error)
            }
        }
    }

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text message: \(text)")
                    DispatchQueue.main.async {
                        self?.messages.append(text)
                    }
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
                self?.receive()
            case .failure(let error):
                print("Failed to receive message: \(error)")
            }
        }
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("didOpenWithProtocol")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("didCloseWith: closeCode: \(closeCode) reason: \(String(describing: reason))")
    }
}
