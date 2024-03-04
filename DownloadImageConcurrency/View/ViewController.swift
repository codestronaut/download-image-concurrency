import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var movieTableView: UITableView!
    
    private var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        movieTableView.dataSource = self
        movieTableView.layoutMargins = UIEdgeInsets.zero
        movieTableView.separatorInset = UIEdgeInsets.zero
        movieTableView.register(
            UINib(nibName: "MovieTableViewCell", bundle: nil),
            forCellReuseIdentifier: "movieTableViewCell"
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await getMovies() }
    }
    
    func getMovies() async {
        let network = NetworkService()
        
        do {
            movies = try await network.getMovies()
            movieTableView.reloadData()
        } catch {
            fatalError("Error: connection failed.")
        }
    }
    
    fileprivate func startDownload(movie: Movie, indexPath: IndexPath) {
        let imageDownloader = ImageDownloader()
        if movie.state == .new {
            Task {
                do {
                    let image = try await imageDownloader.downloadImage(url: movie.posterPath)
                    movie.state = .downloaded
                    movie.image = image
                    self.movieTableView.reloadRows(at: [indexPath], with: .automatic)
                } catch {
                    movie.state = .failed
                    movie.image = nil
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "movieTableViewCell", 
            for: indexPath
        ) as? MovieTableViewCell {
            let movie = movies[indexPath.row]
            cell.movieTitle.text = movie.title
            cell.movieImage.image = movie.image
            
            if movie.state == .new {
                cell.loadingIndicator.isHidden = false
                cell.loadingIndicator.startAnimating()
                startDownload(movie: movie, indexPath: indexPath)
            } else {
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
