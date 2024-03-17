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
    
    var undoManager = UndoManager()
    
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
                AddMovieView(isPresented: $isAddMovieViewPresented, undoManager: undoManager)
                    .environment(\.managedObjectContext, managedObjectContext)
            }
        }
        .onAppear {
            managedObjectContext.undoManager = undoManager
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
    private func deleteMovie(at offsets: IndexSet) {
        offsets.forEach { index in
            let movie = movies[index]
            managedObjectContext.delete(movie)
        }
        // 삭제시 삭제된 데이터를 undoManager에 등록해놓는다.
        // 되돌릴시 데이터가 복구된다.
        undoManager.registerUndo(withTarget: managedObjectContext) { context in
            if context.deletedObjects.count != 0 {
                let changedValue = context.deletedObjects
                
                if changedValue.count == 1 {
                    context.insert(changedValue.first!)
                } else {
                    for movie in changedValue {
                        context.insert(movie)
                    }
                }
            }
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving Managed Object Context : \(error.localizedDescription)")
        }
    }
    
    private func undoContext() {
        managedObjectContext.undo()
        saveContext()
    }
    
    private func resetContext() {
        for movie in movies {
            managedObjectContext.delete(movie)
        }
        
        undoManager.registerUndo(withTarget: managedObjectContext) { context in
            if context.deletedObjects.count != 0 {
                let changedValue = context.deletedObjects
                
                if changedValue.count == 1 {
                    context.insert(changedValue.first!)
                } else {
                    for movie in changedValue {
                        context.insert(movie)
                    }
                }
            }
        }
        saveContext()
    }
}




