import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string icon: "󰖙"
    property string temperature: "--°C"

    property string nextIcon: "󰖐"
    property string nextTemperature: "--°C"

    property bool loading: false
    property string errorMessage: ""

    Process {
        id: getWeather

        command: [
            "sh",
            "-c",
            "curl -fsSL --max-time 10 'https://api.open-meteo.com/v1/forecast?latitude=20.57&longitude=-101.19&current=temperature_2m,weather_code&hourly=temperature_2m,weather_code&timezone=auto&forecast_days=2'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length === 0) {
                    root.errorMessage = "Sin datos"
                    root.loading = false
                    return
                }

                try {
                    const data = JSON.parse(text)

                    if (!data.current || !data.hourly) {
                        root.errorMessage = "Respuesta inválida"
                        root.loading = false
                        return
                    }

                    // Temperatura actual
                    root.temperature =
                        Math.round(data.current.temperature_2m) + "°C"

                    root.icon =
                        root.weatherIcon(data.current.weather_code)

                    // Buscar la siguiente hora
                    const currentTime = data.current.time
                    const hourlyTimes = data.hourly.time

                    let nextIndex = hourlyTimes.indexOf(currentTime)

                    if (nextIndex < 0)
                        nextIndex = 0

                    nextIndex++

                    if (nextIndex < data.hourly.temperature_2m.length) {
                        root.nextTemperature =
                            Math.round(
                                data.hourly.temperature_2m[nextIndex]
                            ) + "°C"

                        root.nextIcon =
                            root.weatherIcon(
                                data.hourly.weather_code[nextIndex]
                            )
                    }

                    root.errorMessage = ""
                } catch (e) {
                    root.errorMessage = "Error del clima"
                    console.log("Weather JSON error:", e)
                }

                root.loading = false
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    console.log("Weather error:", text)
            }
        }
    }

    Timer {
        interval: 600000
        running: true
        repeat: true

        onTriggered: root.refresh()
    }

    function refresh() {
        if (getWeather.running)
            return

        root.loading = true
        getWeather.running = true
    }

    function weatherIcon(code) {
        if (code === 0)
            return "󰖙"

        if (code === 1 || code === 2)
            return "󰖕"

        if (code === 3)
            return "󰖐"

        if (code >= 45 && code <= 48)
            return "󰖑"

        if (code >= 51 && code <= 67)
            return "󰖗"

        if (code >= 71 && code <= 77)
            return "󰖘"

        if (code >= 80 && code <= 82)
            return "󰖖"

        if (code >= 95)
            return "󰖓"

        return "󰖙"
    }

    Component.onCompleted: refresh()
}