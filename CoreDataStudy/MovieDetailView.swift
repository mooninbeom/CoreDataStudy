//
//  MovieDetailView.swift
//  CoreDataStudy
//
//  Created by 문인범 on 3/16/24.
//

import SwiftUI

struct MovieDetailView: View {
    var movie: Movie?
    
    var body: some View {
        VStack {
            Text(movie?.title ?? "Empty Title!")
            Text(movie?.genre ?? "Empty Genre!")
            
            if let date = movie?.releaseDate {
                Text(date, style: .date)
            } else {
                Text(Date(), style: .date)
            }
        }
    }
}

#Preview {
    MovieDetailView()
}
