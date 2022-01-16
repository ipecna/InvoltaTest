//
//  NetworkManager.swift
//  InvoltaTest
//
//  Created by Semyon Chulkov on 13.01.2022.


import Foundation

class NetworkManager {
    
    let dataURL = "https://a-prokudin.node-api.numerology.dev-03.h.involta.ru/getMessages?offset="
    var delegate: NetworkManagerDelegate?
    //this is basically the index of the first message we want to load
    var offset = 0
    
    func fetchData(with offset: Int = 0) {
        let url = dataURL + "\(offset)"
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        let url = URL(string: urlString)!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            if error == nil {
                if let safeData = data {
                    guard let self = self else { return }
                    guard let testData = self.parseJSON(safeData) else { return }
                    
                    //go to main thread so we can update the UI
                    DispatchQueue.main.async {
                        self.delegate?.didLoadData(self, data: testData)
                    }
                }
            } else {
                guard let self = self else { return }
                
                //go to main thread so we can update the UI
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(error: error!)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(_ testData: Data) -> TestModel? {
        let decoder = JSONDecoder()
        do {
            let data = try decoder.decode(TestData.self, from: testData)
            let results = data.result
            return TestModel(messages: results)
        } catch {
            //go back to main to update UI
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didFailWithError(error: error)
            }
            return nil
        }
    }
}
