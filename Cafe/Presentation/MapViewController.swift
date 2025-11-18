import UIKit
import MapboxMaps

class MapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MapView(frame: view.bounds)
        let cameraOptions = CameraOptions(center:
            CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0),
            zoom: 2, bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
    }
}
