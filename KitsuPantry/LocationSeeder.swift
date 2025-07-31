//
//  LocationSeeder.swift
//  KitsuPantry
//
//  Created by Silver on 7/28/25.
//

import CoreData

func seedDefaultLocations(context: NSManagedObjectContext) {
    let request: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()

    do {
        let count = try context.count(for: request)
        if count == 0 {
            let defaults: [(String, Bool, Bool)] = [
                ("All", true, true),        // isDefault = true, isProtected = true
                ("Fridge", true, false),
                ("Freezer", true, false),
                ("Pantry", true, false)
            ]

            for (name, isDefault, isProtected) in defaults {
                let location = LocationEntity(context: context)
                location.name = name
                location.isDefault = isDefault
                location.isProtected = isProtected
            }

            try context.save()
        }
    } catch {
        print("Failed to seed locations: \(error)")
    }
}
