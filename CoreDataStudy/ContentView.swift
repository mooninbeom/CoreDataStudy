//
//  ContentView.swift
//  CoreDataStudy
//
//  Created by 문인범 on 3/16/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Movie.entity(),
        sortDescriptors: [.init(keyPath: \Movie.title, ascending: true)],
        animation: .spring)
    var movies: FetchedResults<Movie>
    
    @State var isAddMovieViewPresented: Bool = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if movies.isEmpty {
                    Text("Empty!")
                } else {
                    List {
                        ForEach(movies) { movie in
                            NavigationLink(movie.title ?? "nil") {
                                MovieDetailView(movie: movie)
                            }
                        }
                        .onDelete(perform: deleteMovie)
                    }
                }
            }
            .navigationTitle("Movie List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addButton) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $isAddMovieViewPresented) {
                AddMovieView(isPresented: $isAddMovieViewPresented)
                    .environment(\.managedObjectContext, managedObjectContext)
            }
        }
    }
    
    func addButton() {
        isAddMovieViewPresented.toggle()
    }
}


#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistentController.shared.container.viewContext)
}


// MARK: - Core Data CRUD
extension ContentView {
    private func addMovie(title: String, genre: String, releaseDate: Date) {
        let movie = Movie(context: managedObjectContext)
        
        movie.title = title
        movie.genre = genre
        movie.releaseDate = releaseDate
        
        saveContext()
    }
    
    private func deleteMovie(at offsets: IndexSet) {
        offsets.forEach { index in
            let movie = movies[index]
            managedObjectContext.delete(movie)
            
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving Managed Object Context : \(error.localizedDescription)")
        }
    }
}
