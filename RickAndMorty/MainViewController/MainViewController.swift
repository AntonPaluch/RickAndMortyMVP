import UIKit

//MARK: - MainViewProtocol

protocol MainViewProtocol: AnyObject {
    func reloadData()
}

final class MainViewController: UIViewController {
    
    private var presenter: MainViewPresenterProtocol!
    
    let urlApi = URLS.rickandmortyapi.rawValue

    private lazy var mainTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.register(MainViewTableViewCell.self, forCellReuseIdentifier: MainViewTableViewCell.cellIdentifier)
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = 100
        return tableView
    }()
    
    //MARK: - Life Circle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainTableView)
        mainTableView.dataSource = self
        mainTableView.delegate = self
        setupConstraints()
        setNavigationBar()
        let networkManager = NetworkManager()
        presenter = MainViewPresenter(view: self, networkManager: networkManager)
        presenter.fetchData(from: urlApi)
    }
    
    func setNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationController?.navigationBar.topItem?.title = "Rick and Morty"
        UINavigationBar.appearance().backgroundColor = #colorLiteral(red: 0.9709939361, green: 0.9568827748, blue: 0.9220435023, alpha: 1)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 0.2823102176, green: 0.1690107286, blue: 0.146335572, alpha: 1)]
        navigationBar?.standardAppearance = navigationBarAppearance
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(rightHandAction))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(leftHandAction))
    }

    @objc func rightHandAction() {
        presenter.fetchData(from: presenter.rickAndMorty?.info.next ?? "1")
    }
    
    @objc func leftHandAction() {
        presenter.fetchData(from: presenter.rickAndMorty?.info.prev ?? "1")
    }
    
    private func setupConstraints() {
        mainTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
}
}

//MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.rickAndMorty?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewTableViewCell.cellIdentifier, for: indexPath) as? MainViewTableViewCell else { return UITableViewCell() }
        let data = presenter.rickAndMorty?.results[indexPath.row]
        cell.configure(with: data)
        return cell
    }
}

// MARK: - TableView delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let result = presenter.rickAndMorty?.results[indexPath.row] else {return}
        let detailVC = ModuleAssembler.createDetailModule(result: result)
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true, completion: nil)
    }
    
}

//MARK: - MainViewProtocol

extension MainViewController: MainViewProtocol {
    func reloadData() {
        mainTableView.reloadData()
    }
}
