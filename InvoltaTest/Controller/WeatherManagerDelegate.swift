//
//  WeatherManagerDelegate.swift
//  InvoltaTest
//
//  Created by Semyon Chulkov on 13.01.2022.
//

import Foundation

protocol NetworkManagerDelegate {
    func didLoadData(_ networkManager: NetworkManager, data: TestModel)
    
    func didFailWithError(error: Error)
}
