import QtQuick
import QtQuick.Controls
import org.qfield
import org.qgis

Item {
    id: root

    // Añade un botón flotante en la barra de herramientas del mapa al cargar el plugin
    Component.onCompleted: {
        iface.addItemToPluginsToolbar(gmapsButton)
    }

    // Campo de texto invisible auxiliar para copiar al portapapeles de forma fiable en Android/iOS
    TextEdit {
        id: clipboardHelper
        visible: false
    }

    // Botón del plugin
    QfToolButton {
        id: gmapsButton
        iconSource: Theme.getThemeVectorIcon("ic_map_white_24dp")
        iconColor: Theme.mainColor
        bgcolor: Theme.darkGray
        round: true

        onClicked: {
            var mapCanvas = iface.mapCanvas()
            if (!mapCanvas) {
                iface.mainWindow().displayToast("No se pudo acceder al mapa")
                return
            }

            // 1. Obtener el punto central actual del mapa (en el CRS del proyecto, ej. EPSG:32630)
            var centerPoint = mapCanvas.mapSettings.extent.center()
            var sourceCrs = mapCanvas.mapSettings.destinationCrs

            // 2. Definir WGS84 (EPSG:4326) como destino
            var destCrs = CoordinateReferenceSystemUtils.fromDescription("EPSG:4326")

            // 3. Reproyectar el punto al vuelo
            var wgs84Point = GeometryUtils.reprojectPoint(centerPoint, sourceCrs, destCrs)

            // En EPSG:4326, 'y' es Latitud y 'x' es Longitud (6 decimales = precisión ~11 cm)
            var lat = wgs84Point.y.toFixed(6)
            var lon = wgs84Point.x.toFixed(6)
            var coordsText = lat + ", " + lon

            // 4. Copiar al portapapeles por si necesitas pegarlas manualmente
            clipboardHelper.text = coordsText
            clipboardHelper.selectAll()
            clipboardHelper.copy()

            iface.mainWindow().displayToast("Abriendo Maps: " + coordsText)

            // 5. Abrir directamente en Google Maps (navegador o app nativa)
            var url = "https://www.google.com/maps/search/?api=1&query=" + lat + "," + lon
            Qt.openUrlExternally(url)
        }
    }
}
