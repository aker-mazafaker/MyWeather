//
//  ViewController.swift
//  weather
//
//  Created by Akerke on 17.09.2023.
//

import UIKit
import SnapKit
import CoreLocation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let colView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 15
            layout.itemSize = CGSize(width: 150, height: 200)
            return layout
        }()
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        return view
    }()
    
    let api = "04bdc737adf5f846de786297efd3af9d"
    var lastApiRequestTime: Date?
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    
    
    let secondViewController = SecondViewController()
    
    let backImage: UIImageView = {
        let image = UIImageView(frame: UIScreen.main.bounds)
        image.image = UIImage(named: "almaty")
        image.contentMode = .scaleToFill
        return image
    }()
    
    let degreesLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.shadowColor = .yellow
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Bold", size: 70)
        return label
    }()
    
    let adviceLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica-Bold", size: 56)
        
        return label
    }()
    
    
    private func setupNavigationBar() {
        title = "WEATHER"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(moveToSecondScreen) )
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .purple
        
    }
    
    @objc func moveToSecondScreen() { // remove @objc for Swift 3
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        makeConstraints()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        colView.delegate = self
        colView.dataSource = self
        colView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
    }
}

extension ViewController {
    func setupScene() {
        self.view.insertSubview(backImage, at: 0)
        view.addSubview(degreesLabel)
        view.addSubview(adviceLabel)
        view.addSubview(colView)
        
    }
    func makeConstraints() {
        degreesLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview().offset(-50)
            $0.centerY.equalToSuperview().offset(-200)
        }
        adviceLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview().offset(100)
        }
        colView.snp.makeConstraints{
            $0.bottom.equalToSuperview().offset(-20)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(250)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil {
            let currentTime = Date()
            if let lastRequestTime = lastApiRequestTime, currentTime.timeIntervalSince(lastRequestTime) < 300 {
                return
            }
            
            let latitude = 43.2566700
            let longitude = 76.9286100
            
            let url = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly&units=metric&appid=04bdc737adf5f846de786297efd3af9d"
            print(url)
            AF.request(url).responseJSON { response in
                if let data = response.data {
                    let decoder = JSONDecoder()
                    do {
                        let weatherData = try decoder.decode(WeatherData.self, from: data)
                        DispatchQueue.main.async {
                            self.degreesLabel.text = String(weatherData.current.temp)
                            self.degreesLabel.text = "\(weatherData.current.temp)°C"
                            self.adviceLabel.text = weatherData.current.weather.first?.description
                            
                        }
                        print(weatherData)
                        
                    } catch {
                        print("Ошибка декодирования данных: \(error)")
                    }
                }
            }
        }
    }
    
    //    func updateUI(with weather: WeatherData) {
    //
    //        let numberFormatter = NumberFormatter()
    //        numberFormatter.maximumFractionDigits = 2
    //
    //        let temperatureText = numberFormatter.string(from: NSNumber(value: temperatureCelsius)) ?? ""
    //        let formattedTemperatureText = "\(temperatureText)°C"
    //        let descriptionText = weather.current.weather.first?.description
    //
    //        degreesLabel.text = formattedTemperatureText
    //        adviceLabel.text = descriptionText
    //    }
    //}
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let color = UIColor(named: "Color")
        cell.backgroundColor = color
        return cell
    }
}

class WeatherCell: UICollectionViewCell {
    let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let degreesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ text: String) {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}


private extension WeatherCell {
    func setupCell() {
        contentView.backgroundColor = .systemGray5
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(degreesLabel)
        stackView.addArrangedSubview(emojiLabel)
        contentView.addSubview(stackView)
    }
    
    func makeConstraints() {
        stackView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
}


