//
//  DeviceConnection.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

public enum ResultType<Value, Err: Error> {
    case success(Value)
    case failure(Err)
}

public enum ConnectionError: Error {
    case noSpaceAvailable
    case jsonParseError
    case couldNotConnect
    case timeout
}

public protocol DeviceConnectionDelegate: class {
    func deviceConnection(connection: DeviceConnection, didReceiveData data: String)
    func deviceConnection(connection: DeviceConnection, didUpdateState state: DeviceConnectionState)
}

public enum DeviceConnectionState {
    case opened
    case closed
    case openTimeout
    case error
    case unknown
}

public class DeviceConnection: NSObject {
    
    var ipAddress: String = ""
    var port: Int = 0
    
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    var timeoutTimer: Timer?
    
    var receivedDataBuffer = ""
    var streamState: (input: Bool, output: Bool) = (false, false)
    
    var isOpen: Bool {
        return (true, true) == streamState
    }
    
    weak var delegate: DeviceConnectionDelegate?
    
    
    // MARK: Life cycle
    
    init(withIPAddress ipAddress: String, port: Int) {
        self.ipAddress = ipAddress
        self.port = port
        
        super.init()
        
        initSocket()
        
        timeoutTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(self.socketOpenTimeoutHandler(timer:)), userInfo: nil, repeats: false)
        RunLoop.current.add(timeoutTimer!, forMode: .commonModes)
    }
    
    deinit {
        close()
    }
    
    // should throw stream error if not inited
    private func initSocket() {
        
        Stream.getStreamsToHost(withName: ipAddress, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        guard let inputStream = inputStream,
            let outputStream = outputStream else { return }
        
        [inputStream, outputStream].forEach { stream in
            stream.delegate = self
            stream.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        }
        
        inputStream.open()
        outputStream.open()
    }
    
    @objc func socketOpenTimeoutHandler(timer: Timer) {
        timer.invalidate()
        delegate?.deviceConnection(connection: self, didUpdateState: .openTimeout)
    }
    
    func writeString(_ string: String) {
        guard isOpen,
            let buffer = string.data(using: .utf8, allowLossyConversion: true),
            let outputStream = outputStream else {
                delegate?.deviceConnection(connection: self, didUpdateState: .error)
                return
        }
        
        
        DispatchQueue.main.async { [unowned self] in
            if outputStream.hasSpaceAvailable {
                let _ = buffer.withUnsafeBytes { outputStream.write($0, maxLength: buffer.count) }
            } else {
                self.delegate?.deviceConnection(connection: self, didUpdateState: .error)
            }
        }
    }
    
    private func close() {
        timeoutTimer?.invalidate()
        
        outputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
        outputStream?.close()
        
        inputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
        inputStream?.close()
    }
}


// MARK: Stream delegate

extension DeviceConnection: StreamDelegate {
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode == .openCompleted {
            
            if aStream == inputStream {
                streamState = (true, streamState.output)
            }
            if aStream == outputStream {
                streamState = (streamState.input, true)
            }
            
            if case (true, true) = streamState {
                delegate?.deviceConnection(connection: self, didUpdateState: .opened)
            }
            return
        }
        
        if eventCode == .hasSpaceAvailable || eventCode == .hasBytesAvailable {
            guard let inputStream = inputStream else { return }
            
            if aStream == inputStream {
                var buffer = [UInt8](repeatElement(0, count: 1024))
                while inputStream.hasBytesAvailable {
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if let data = String(bytesNoCopy: &buffer, length: len, encoding: .ascii, freeWhenDone: false) {
                        receivedDataBuffer.append(data)
                    }
                }
            }
            return
        }
        
        if eventCode == .endEncountered {
            
            timeoutTimer?.invalidate()
            
            if aStream == outputStream {
                streamState = (streamState.input, false)
            }
            if aStream == inputStream {
                streamState = (false, streamState.output)
                if case (_, true) = streamState {
                    outputStream?.close()
                }
                delegate?.deviceConnection(connection: self, didUpdateState: .closed)
                if !receivedDataBuffer.isEmpty {
                    delegate?.deviceConnection(connection: self, didReceiveData: receivedDataBuffer)
                }
            }
            return
        }
        
        if eventCode == .errorOccurred {
            delegate?.deviceConnection(connection: self, didUpdateState: .error)
            return
        }
    }
}
