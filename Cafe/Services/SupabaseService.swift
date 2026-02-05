//
//  SupabaseService.swift
//  Cafe
//
//  Created by Антон Абалуев on 21.12.2025.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://ahasxpolxjysjrcvulgw.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoYXN4cG9seGp5c2pyY3Z1bGd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNTMzMjUsImV4cCI6MjA3NzkyOTMyNX0.hGakP8HMHj3BgfS-lpM0kz1xZ8QV26tD4KjWSYo4gfI"
        )
    }
}
