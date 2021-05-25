//
//  AppDelegate.swift
//  tief viewer
//
//  Created by Алексей Петров on 24.05.2021.
//

import Cocoa
import Combine

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var mainMenu: NSMenu!
    
    @IBAction func tapOnNewFile(_ sender: Any) {
        ActionProvider.shared.send(action: .openFile)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

class ActionProvider {
    
    static let shared = ActionProvider()
    
    enum Action {
        case openFile
        case close
    }
    
    private var actionProvider = PassthroughSubject<Action, Never>()
    
    fileprivate func send(action: Action) {
        actionProvider.send(action)
    }
    
    func actions() -> AnyPublisher<Action, Never> {
        actionProvider.eraseToAnyPublisher()
    }
    
    func subscribeTo(_ action: Action) -> AnyPublisher<Action, Never> {
        actionProvider
            .flatMap { receivedAction -> AnyPublisher<Action, Never> in
                if action == receivedAction {
                    return Just(action).eraseToAnyPublisher()
                }
                
                return Empty().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
