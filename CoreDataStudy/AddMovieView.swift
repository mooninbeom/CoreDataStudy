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
        
        // 10초가 지날 시 자동으로 저장된다.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 15) {
            do {
                try managedObjectContext.save()
            } catch {
                fatalError()
            }
        }
        
        isPresented.toggle()
    }
}

#Preview {
    AddMovieView(isPresented: .constant(true))
}
