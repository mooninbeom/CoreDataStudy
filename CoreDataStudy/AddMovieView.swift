//
//  AddMovieView.swift
//  CoreDataStudy
//
//  Created by 문인범 on 3/16/24.
//

import SwiftUI

struct AddMovieView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var title: String = ""
    @State private var genre = ""
    @State private var releaseDate: Date = Date()
    
    @Binding var isPresented: Bool
    
    @FocusState private var focusField: Field?
    
    var undoManager: UndoManager
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(text: $title) {
                        Text("영화 타이틀")
                    }
                    .focused($focusField, equals: .title)
                }
                Section {
                    TextField(text: $genre) {
                        Text("장르")
                    }
                    .focused($focusField, equals: .genre)
                }
                DatePicker("개봉 날짜", selection: $releaseDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        doneButtonAction()
                    } label: {
                        Text("Done")
                    }
                    .disabled( (title.isEmpty || genre.isEmpty) ? true : false )
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusField = .title
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusField = .genre
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                }
            }
        }
    }
    
    enum Field {
        case title
        case genre
    }
    
    
    private func doneButtonAction() {
        if title.isEmpty {
            focusField = .title
            return
        }
        
        if genre.isEmpty {
            focusField = .genre
            return
        }
        focusField = nil
        
        let movie = Movie(context: managedObjectContext)
        movie.title = title
        movie.genre = genre
        movie.releaseDate = releaseDate
        
        // 데이터 추가시 undoManager에 추가된 데이터를 등록해놓는다.
        // 되돌릴시 데이터가 삭제된다.
        undoManager.registerUndo(withTarget: managedObjectContext) { context in
            if context.insertedObjects.count != 0 {
                let changedValue = context.insertedObjects
                
                if changedValue.count == 1 {
                    context.delete(changedValue.first!)
                }
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError()
        }
        
        isPresented.toggle()
    }
}

#Preview {
    AddMovieView(isPresented: .constant(true), undoManager: UndoManager())
}
