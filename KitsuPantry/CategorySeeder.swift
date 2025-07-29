//
//  CategorySeeder.swift
//  KitsuPantry
//
//  Created by Silver on 7/28/25.
//

import CoreData

func seedDefaultCategories(context: NSManagedObjectContext) {
    let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()

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
                let category = CategoryEntity(context: context)
                category.name = name
                category.isDefault = isDefault
                category.isProtected = isProtected
            }

            try context.save()
        }
    } catch {
        print("Failed to seed categories: \(error)")
    }
}
