//
//  DeviceCommunicationManager.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

public class DeviceCommunicationManager: DeviceConnectionDelegate {
    static let ConnectionEndpointAddress = "192.168.0.1"
    static let ConnectionEndpointPortString = "5609"
    static let ConnectionEndpointPort = 5609;
    
    var connection: DeviceConnection?
    
    var connectionCommand: (() -> Void)?
    var completionCommand: ((ResultType<[AnyHashable: Any], ConnectionError>) -> Void)?

    public func sendCommand<T: ParticleCommunicable>(_ type: T.Type, completion: @escaping (ResultType<T.ResponseType, ConnectionError>) -> Void) {
    
        runCommand(onConnection: { connection in
            connection.writeString(T.command)
        }, onCompletion: { result in
            switch result {
            case .success(let json):
                if let stuff = T.parse(json) {
                    completion(.success(stuff))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func runCommand(onConnection: @escaping (DeviceConnection) -> Void,
                            onCompletion: @escaping (ResultType<[AnyHashable: Any], ConnectionError>) -> Void) {
        
        guard DeviceCommunicationManager.canSendCommandCall() else { return }
        
        completionCommand = onCompletion
        openConnection { connection in
            onConnection(connection)
        }
    }
    
    private func openConnection(withCommand command: @escaping (DeviceConnection) -> Void) {
        let ipAddress = DeviceCommunicationManager.ConnectionEndpointAddress
        let port = DeviceCommunicationManager.ConnectionEndpointPort
        connection = DeviceConnection(withIPAddress: ipAddress, port: port)
        
        connection!.delegate = self;
        
        connectionCommand = { [unowned self] in
            command(self.connection!)
        }
    }
    
    private class func canSendCommandCall() -> Bool {
        
        // TODO: refer to original source
        
        if !Wifi.isDeviceConnected(.photon) {
            return false
        }
        
        return true
    }
}

// MARK: - DeviceConnectionDelegate

extension DeviceCommunicationManager {
    public func deviceConnection(connection: DeviceConnection, didReceiveData data: String) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: .allowFragments) as? [AnyHashable: Any] else {
                completionCommand?(.failure(ConnectionError.jsonParseError))
                return
            }
            completionCommand?(.success(json))
        }
        catch {
            completionCommand?(.failure(ConnectionError.jsonParseError))
        }
    }
    
    public func deviceConnection(connection: DeviceConnection, didUpdateState state: DeviceConnectionState) {
        switch state {
        case .opened:
            connectionCommand?()
        case .openTimeout:
            completionCommand?(.failure(ConnectionError.timeout))
        case .error:
            completionCommand?(.failure(ConnectionError.couldNotConnect))
        default: break
        }
    }
}
