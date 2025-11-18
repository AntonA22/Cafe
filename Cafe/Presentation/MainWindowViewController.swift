//
//  MainWindowViewController.swift
//  Cafe
//
//  Created by Антон Абалуев on 12.11.2025.
//


import Foundation
import Supabase
import UIKit

struct Profile: Codable {
    let id: Int
    let email: String
    let name: String
}

final class MainWindowViewController: UIViewController {
    
    // MARK: - Fetch Users
    func fetchAllUsers() async {
        do {
            // Получаем всех пользователей
            let response: PostgrestResponse<[Profile]> = try await supabase
                .from("users_swift")
                .select()
                .execute()
            
            let users = response.value
            
            // Создаём строку для отображения
            var displayText = ""
            for user in users {
                displayText += "User ID: \(user.id)\nEmail: \(user.email)\nName: \(user.name)\n\n"
            }
            
            // Обновляем UI на главном потоке
            DispatchQueue.main.async {
                self.textView.text = displayText
            }
            
        } catch {
            DispatchQueue.main.async {
                self.textView.text = "Error fetching users: \(error)"
            }
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Вызываем функцию для загрузки пользователей
        Task {
            await fetchAllUsers()
        }
    }
        
}
