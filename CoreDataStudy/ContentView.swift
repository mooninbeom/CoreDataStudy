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
    @State private var isUndoAlertPresented: Bool = false
    @State private var isResetAlertPresented: Bool = false
    
    
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
                    Button {
                        isAddMovieViewPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isResetAlertPresented.toggle()
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                    }
                }
            }
            .sheet(isPresented: $isAddMovieViewPresented) {
                AddMovieView(isPresented: $isAddMovieViewPresented)
                    .environment(\.managedObjectContext, managedObjectContext)
            }
        }
        .onShakeGesture {
            isUndoAlertPresented.toggle()
        }
        .alert("되돌리시겠습니까?", isPresented: $isUndoAlertPresented) {
            Button("취소", role: .cancel, action: { isUndoAlertPresented.toggle() })
            Button("되돌리기", role: ButtonRole.destructive, action: undoContext)
        }
        .alert("리셋하시겠습니까?", isPresented: $isResetAlertPresented) {
            Button("취소", role: .cancel, action: { isResetAlertPresented.toggle() })
            Button("리셋하기", role: .destructive, action: resetContext)
        }
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                saveContext()
            }
        }
    }
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving Managed Object Context : \(error.localizedDescription)")
        }
    }
    
    private func undoContext() {
        let undoManager = UndoManager()
        managedObjectContext.undoManager = undoManager
        
        // 삭제되었을시 다시 insert, insert 된 것을 되돌려 삭제하기
        undoManager.registerUndo(withTarget: managedObjectContext) { context in
            if let changedValue = context.insertedObjects.first {
                context.delete(changedValue)
            }
            
            if !context.deletedObjects.isEmpty {
                var deletedMovies = context.deletedObjects
                
                if deletedMovies.count == 1 {
                    context.insert(context.deletedObjects.first!)
                } else {
                    for movie in deletedMovies {
                        context.insert(movie)
                    }
                }
            }
        }
        
        managedObjectContext.undo()
        
        saveContext()
    }
    
    private func resetContext() {
        saveContext()
        
        for movie in movies {
            managedObjectContext.delete(movie)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            saveContext()
            print("Hello~")
        }
        
    }
}
