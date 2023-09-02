//
//  BitcoinPriceManager.swift
//  Calculator
//
//  Created by Nuwan Jayasinghe on 2023-09-03.
//

import Foundation

public class BitcoinPriceManager {
    private static let shared = BitcoinPriceManager()
    
    private init() {}
    
    static func sharedManager() -> BitcoinPriceManager {
        return shared
    }
    
    private var lastKnownPrice: Double?
    
    func getBitcoinPrice(completion: @escaping (Result<Double, Error>) -> Void) {
        let isOnline = Reachability.isConnectedToNetwork()
        
        if isOnline {
            let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd")!
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "Data is nil", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let bitcoinData = json["bitcoin"] as? [String: Any],
                       let usdPrice = bitcoinData["usd"] as? Double {
                        self.lastKnownPrice = usdPrice
                        completion(.success(usdPrice))
                    } else {
                        completion(.failure(NSError(domain: "Parsing Error", code: 0, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        } else {
            if let lastPrice = lastKnownPrice {
                completion(.success(lastPrice))
            } else {
                completion(.failure(NSError(domain: "No offline data available", code: 0, userInfo: nil)))
            }
        }
    }
}

