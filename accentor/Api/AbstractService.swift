//
//  AbstractService.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/11/2022.
//

import Foundation
import CoreData

class AbstractService {
    public static let shared = AbstractService()
    
    func index(path: String, completion: @escaping (Data) -> ()) {
        self.fetchPage(page: 1, path: path, completion: completion)
    }
    
    private func fetchPage(page: Int, path: String, completion: @escaping (Data) -> ()) {

        var components = URLComponents(url: UserDefaults.standard.url(forKey: "serverURL")!, resolvingAgainstBaseURL: true)!
        components.path = "/api/" + path
        
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        var request = URLRequest(url: components.url!)
        request.addValue(UserDefaults.standard.string(forKey: "deviceId")!, forHTTPHeaderField: "x-device-id")
        request.addValue(UserDefaults.standard.string(forKey: "secret")!, forHTTPHeaderField: "x-secret")
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, res, _) in
            guard let jsonData = data else { return }
            let response = res as! HTTPURLResponse
            
            if response.statusCode != 200 {
                print("Error in API")
                return
            }
            
            completion(jsonData)
            
            let totalPages = Int(response.value(forHTTPHeaderField: "x-total-pages")!) ?? 0
            if (page < totalPages) {
                self.fetchPage(page: page + 1, path: path, completion: completion)
            }
        }.resume()
    }
    
    func removeOld(entityName: String, beforeDate: NSDate) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "fetchedAt < %@", beforeDate)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        deleteRequest.resultType = .resultTypeObjectIDs

        // Get a reference to a managed object context
        let context = PersistenceController.shared.container.viewContext

        // Perform the batch delete
        let batchDelete = try? context.execute(deleteRequest)
            as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result
            as? [NSManagedObjectID]
            else { return }

        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]

        // Merge the delete changes into the managed
        // object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
    }
}
