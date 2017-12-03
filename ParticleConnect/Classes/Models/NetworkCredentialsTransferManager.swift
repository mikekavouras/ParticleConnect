//
//  NetworkCredentialsTransferManager.swift
//  Nimble
//
//  Created by Mike on 12/2/17.
//

protocol NetworkCredentialsTransferManagerDelegate: class {
    func networkCredentialsTransferManagerDidConfigureDeviceNetworkCredentials(_ manager: NetworkCredentialsTransferManager)
    func networkCredentialsTransferManagerDidConnectDeviceToNetwork(_ manager: NetworkCredentialsTransferManager)
}

extension NetworkCredentialsTransferManagerDelegate where Self: UIViewController {
    func networkCredentialsTransferManagerDidConfigureDeviceNetworkCredentials(_ manager: NetworkCredentialsTransferManager) {}
}

class NetworkCredentialsTransferManager {
    
    var network: Network!
    var communicationManager: DeviceCommunicationManager?
    weak var delegate: NetworkCredentialsTransferManagerDelegate?
    
    func transferCredentials(`for` network: Network) {
        self.network = network
        
        configureDeviceNetworkCredentials {
            self.connectDeviceToNetwork()
        }
    }
    
    private func configureDeviceNetworkCredentials(_ completion: @escaping () -> Void) {
        communicationManager = DeviceCommunicationManager()
        communicationManager?.configureAP(network: network) { [unowned self] result in
            switch result {
            case .success:
                self.communicationManager = nil
                self.delegate?.networkCredentialsTransferManagerDidConfigureDeviceNetworkCredentials(self)
                completion()
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    private func connectDeviceToNetwork() {
        communicationManager = DeviceCommunicationManager()
        communicationManager?.connectAP { [unowned self] result in
            switch result {
            case .success:
                self.communicationManager = nil
                self.delegate?.networkCredentialsTransferManagerDidConnectDeviceToNetwork(self)
            case .failure(let error):
                print("error connecting device to network: \(error)")
            }
        }

    }
}
