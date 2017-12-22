//
//  DeviceCommunicationManager.swift
//  ParticleConnect
//
//  Created by Mike on 12/1/17.
//

protocol DeviceCommunicationManagerDelegate: class {
    func deviceCommunicationManager(deviceCommunicationManager: DeviceCommunicationManager, didReceiveDeviceId deviceId: String)
    func deviceCommunicationManagerFailedToReceiveDeviceId(deviceCommunicationManager: DeviceCommunicationManager)
    func deviceCommunicationManagerDidReceivePublicKey(deviceCommunicationManager: DeviceCommunicationManager)
    func deviceCommunicationManagerFailedToReceivePublicKey(deviceCommunicationManager: DeviceCommunicationManager)
}

public class DeviceCommunicationManager: DeviceConnectionDelegate {
    static let ConnectionEndpointAddress = "192.168.0.1"
    static let ConnectionEndpointPortString = "5609"
    static let ConnectionEndpointPort = 5609;
    
    weak var delegate: DeviceCommunicationManagerDelegate?
    
    var connection: DeviceConnection?
    
    var connectionCommand: (() -> Void)?
    var completionCommand: ((ResultType<[AnyHashable: Any], ConnectionError>) -> Void)?

    public func configureAP(network: Network, completion: @escaping (ResultType<[AnyHashable: Any], ConnectionError>) -> Void) {
        runCommand(onConnection: { connection in
            guard let json = network.asJSON,
                let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted),
                let jsonString = String(data: data, encoding: String.Encoding.utf8) else
            {
                completion(.failure(ConnectionError.couldNotConnect))
                return
            }
            let command = String(format: "configure-ap\n%ld\n\n%@", jsonString.count, jsonString)
            connection.writeString(command)
        }, onCompletion: completion)
    }
    
    public func connectAP(completion: @escaping (ResultType<[AnyHashable: Any], ConnectionError>) -> Void) {
        runCommand(onConnection: { connection in
            let request: [AnyHashable: Any] = ["idx":0]
            guard let json = try? JSONSerialization.data(withJSONObject: request, options: .prettyPrinted),
                let jsonString = String(data: json, encoding: String.Encoding.utf8) else
            {
                completion(.failure(ConnectionError.couldNotConnect))
                return
            }
            
            let command = String(format: "connect-ap\n%ld\n\n%@", jsonString.count, jsonString)
            connection.writeString(command)
        }, onCompletion: completion)
    }
    
    private var retried = false
    public func getDeviceId() {
        sendCommand(Command.Device.self) { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let value):
                weakSelf.delegate?.deviceCommunicationManager(deviceCommunicationManager: weakSelf, didReceiveDeviceId: value.deviceId)
            case .failure(let error):
                if error == ConnectionError.timeout {
                    if !weakSelf.retried {
                        weakSelf.retried = true
                        weakSelf.getDeviceId()
                    } else {
                        weakSelf.delegate?.deviceCommunicationManagerFailedToReceiveDeviceId(deviceCommunicationManager: weakSelf)
                    }
                } else {
                    weakSelf.delegate?.deviceCommunicationManagerFailedToReceiveDeviceId(deviceCommunicationManager: weakSelf)
                }
            }
        }
    }
    
    public func getPublicKey() {
        sendCommand(Command.PublicKey.self) { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success:
                weakSelf.delegate?.deviceCommunicationManagerDidReceivePublicKey(deviceCommunicationManager: weakSelf)
            case .failure:
                weakSelf.delegate?.deviceCommunicationManagerFailedToReceivePublicKey(deviceCommunicationManager: weakSelf)
            }
        }
    }
    
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
    
    // MARK - Utility
    
    private class func canSendCommandCall() -> Bool {
        
        // TODO: refer to original source
        
        if !WiFi.isDeviceConnected(.photon) {
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
