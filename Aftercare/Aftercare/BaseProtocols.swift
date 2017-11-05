//
//  BaseProtocols.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/4/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

//MARK: - Base View Controller Protocols

protocol ViewControllerInputProtocol: class {} // In most cases equals Presenter Output Protocol
protocol ViewControllerOutputProtocol: class {} // Update view controller

//MARK: - Base Router Protocol

protocol RouterProtocol: class {}

//MARK: - Base Coordinator Protocols

protocol CoordinatorInputProtocol: class {}
protocol CoordinatorOutputProtocol: class {}

//MARK: - Base Presenter Protocols

protocol PresenterInputProtocol: class {} // Presents Coordinator Output
protocol PresenterOutputProtocol: class {} // Update view controller
