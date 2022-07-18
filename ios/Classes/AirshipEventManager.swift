import Foundation
import AirshipKit

class AirshipEventManager {
    
    static let shared = AirshipEventManager()
    
    let streams: [AirshipEventType: AirshipEventStream]
    
    init() {
        var streams: [AirshipEventType: AirshipEventStream] = [:]
        
        AirshipEventType.allCases.forEach { (eventType) in
            streams[eventType] = AirshipEventStream(eventType)
        }
        
        self.streams = streams
    }
    
    func register(_ registry: FlutterPluginRegistrar) {
        streams.values.forEach { (airshipStream) in
            let eventChannel = FlutterEventChannel(name: airshipStream.name,
                                                   binaryMessenger: registry.messenger())
            
            eventChannel.setStreamHandler(airshipStream)
        }
    }
    
    func notify(_ event: AirshipEvent) {
        streams[event.eventType]?.notify(event)
    }
    
    internal class AirshipEventStream : NSObject, FlutterStreamHandler {
        
        var pendinEvents: [AirshipEvent] = []
        var eventSink : FlutterEventSink?
        
        let eventType : AirshipEventType
        let name : String
        
        init(_ eventType: AirshipEventType) {
            self.eventType = eventType
            self.name = "com.airship.flutter/event/\(eventType.rawValue)"
        }
        
        func notify(_ event: AirshipEvent) {
            if let sink = self.eventSink {
                guard let eventData = event.data,
                      let jsonData = try? JSONUtils.string(eventData, options: JSONSerialization.WritingOptions.fragmentsAllowed)
                else {
                    sink(nil)
                    return
                }
                sink(jsonData)
            } else {
                pendinEvents.append(event)
            }
        }
        
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            eventSink = nil
            return nil
        }
        
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            self.eventSink = events
            if (self.eventSink != nil) {
                pendinEvents.forEach { (event) in
                    notify(event)
                }
                pendinEvents.removeAll()
            }
            return nil
        }
    }
}


