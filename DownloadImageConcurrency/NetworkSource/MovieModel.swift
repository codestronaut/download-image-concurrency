import UIKit

enum DownloadState {
    case new, downloaded, failed
}

class Movie {
    let title: String
    let popularity: Double
    let genres: [Int]
    let voteAverage: Double
    let overview: String
    let releaseDate: Date
    let posterPath: URL
    
    var image: UIImage?
    var state: DownloadState = .new
    
    init(
        title: String,
        popularity: Double,
        genres: [Int],
        voteAverage: Double,
        overview: String,
        releaseDate: Date,
        posterPath: URL
    ) {
        self.title = title
        self.popularity = popularity
        self.genres = genres
        self.voteAverage = voteAverage
        self.overview = overview
        self.releaseDate = releaseDate
        self.posterPath = posterPath
    }
}

struct MovieResponses: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let movies: [MovieResponse]
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case movies = "results"
    }
}

struct MovieResponse: Codable {
    let title: String
    let popularity: Double
    let genres: [Int]
    let voteAverage: Double
    let overview: String
    let releaseDate: Date
    let posterPath: URL
    
    enum CodingKeys: String, CodingKey {
        case title
        case popularity
        case genres = "genre_ids"
        case voteAverage = "vote_average"
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.popularity = try container.decode(Double.self, forKey: .popularity)
        self.genres = try container.decode([Int].self, forKey: .genres)
        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        self.overview = try container.decode(String.self, forKey: .overview)
        
        let dateString = try container.decode(String.self, forKey: .releaseDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        releaseDate = dateFormatter.date(from: dateString)!
        
        let path = try container.decode(String.self, forKey: .posterPath)
        posterPath = URL(string: "https://image.tmdb.org/t/p/w300\(path)")!
    }
}
