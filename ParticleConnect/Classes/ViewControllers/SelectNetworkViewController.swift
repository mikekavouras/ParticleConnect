//
//  SelectNetworkViewController.swift
//  Nimble
//
//  Created by Mike on 12/1/17.
//

import UIKit

public class SelectNetworkViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    NetworkCredentialsTransferManagerDelegate {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let loaderView = LoaderView(frame: .zero)
    
    fileprivate var transferManager: NetworkCredentialsTransferManager?
    fileprivate var communicationManager: DeviceCommunicationManager? = DeviceCommunicationManager()
    let reachability = Reachability()!
    
    var isHostReachable = false
    
    
    fileprivate var networks: [Network] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loaderView.show("Looking for networks")
        
        scanForNetworks { foundNetworks in
            self.networks = foundNetworks
            self.loaderView.hide()
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupTableView()
        setupLoaderView()
        setupReachability()
    }
    
    private func setupTableView() {
        let margins = view.layoutMarginsGuide
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -15.0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 15.0).isActive = true
        tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        tableView.register(NetworkCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupLoaderView() {
        let margins = view.layoutMarginsGuide
        
        view.addSubview(loaderView)
        
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: -50.0).isActive = true
    }
    
    private func setupReachability() {
        reachability.whenReachable = { reachability in
            self.isHostReachable = true
        }
        reachability.whenUnreachable = { _ in
            self.isHostReachable = false
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    private func scanForNetworks(completion: @escaping ([Network]) -> Void) {
        
        // TODO: Retry logic (auto or manual)
    
        communicationManager?.sendCommand(Command.ScanAP.self) { result in
            switch result {
            case .success(let list):
                completion(list)
            case .failure(let error):
                print(error)
            }
            self.communicationManager = nil
        }
    }
    
    fileprivate func displayPasswordDialog(`for` network: Network) {
        let alertController = UIAlertController(title: "Enter Password", message: "Enter the password for \(network.ssid)", preferredStyle: .alert)
        let passwordTextField = { (textField: UITextField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alertController.addTextField(configurationHandler: passwordTextField)
        
        let submitAction = UIAlertAction(title: "Join", style: .default) { _ in
            if let textFields = alertController.textFields,
                let passwordField = textFields.first,
                let password = passwordField.text
            {
                var mutableNetwork = network
                mutableNetwork.password = password
                
                self.transferCredentials(for: mutableNetwork)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func transferCredentials(`for` network: Network) {
        loaderView.show("Transferring credentials")
        
        transferManager = NetworkCredentialsTransferManager()
        transferManager?.delegate = self
        transferManager?.transferCredentials(for: network)
    }
}

// MARK: - UITableViewDataSource

extension SelectNetworkViewController {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NetworkCell
        cell.network = networks[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SelectNetworkViewController {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let network = networks[indexPath.row]
        print(network.ssid)
        
        if network.securityType != .open {
            displayPasswordDialog(for: network)
        } else {
            transferCredentials(for: network)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - NetworkCredentialsTransferManagerDelegate

extension SelectNetworkViewController {
    func networkCredentialsTransferManagerDidConfigureDeviceNetworkCredentials(_ manager: NetworkCredentialsTransferManager) {
        print("finished configuration")
    }
    
    func networkCredentialsTransferManagerDidConnectDeviceToNetwork(_ manager: NetworkCredentialsTransferManager) {
        transferManager = nil // we're done using this
        loaderView.setText("Connecting to network")
        
        // run check to see if we're still connected to the particle wifi for up to 20 seconds
        var retries = 0
        func connect() {
            if Wifi.isDeviceConnected(.photon) == true && retries < 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    retries += 1
                    connect()
                }
            } else {
                if Wifi.isDeviceConnected(.photon) {
                    puts("why are we still connected to the device?")
                } else {
                    loaderView.hide("Connected!")
                    
                    var reachabilityRetries = 0
                    func checkHostReachability() {
                        if !isHostReachable && reachabilityRetries < 20 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                reachabilityRetries += 1
                                checkHostReachability()
                            }
                        } else {
                            if !isHostReachable {
                                print("why aren't we connected :(")
                            } else {
                                print("we got this!")
                            }
                        }
                    }
                    checkHostReachability()
                    // make sure the photon is actually connected to the internet
                }
            }
        }
        
        connect()
    }
}
