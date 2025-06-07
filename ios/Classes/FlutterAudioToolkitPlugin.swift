import Flutter
import UIKit
import AVFoundation
import AudioToolbox
import Accelerate

public class FlutterAudioToolkitPlugin: NSObject, FlutterPlugin {
    private var progressEventSink: FlutterEventSink?
      public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_audio_toolkit", binaryMessenger: registrar.messenger())
        let instance = FlutterAudioToolkitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let progressChannel = FlutterEventChannel(name: "flutter_audio_toolkit/progress", binaryMessenger: registrar.messenger())
        progressChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "convertAudio":
            handleConvertAudio(call: call, result: result)
        case "extractWaveform":
            handleExtractWaveform(call: call, result: result)
        case "isFormatSupported":
            handleIsFormatSupported(call: call, result: result)
        case "getAudioInfo":
            handleGetAudioInfo(call: call, result: result)
        case "trimAudio":
            handleTrimAudio(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleConvertAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String,
              let outputPath = args["outputPath"] as? String,
              let format = args["format"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }
        
        let bitRate = args["bitRate"] as? Int ?? 128000
        let sampleRate = args["sampleRate"] as? Int ?? 44100
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let conversionResult = try self.convertAudioFile(
                    inputPath: inputPath,
                    outputPath: outputPath,
                    format: format,
                    bitRate: bitRate,
                    sampleRate: sampleRate
                )
                DispatchQueue.main.async {
                    result(conversionResult)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "CONVERSION_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    private func handleExtractWaveform(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing inputPath", details: nil))
            return
        }
        
        let samplesPerSecond = args["samplesPerSecond"] as? Int ?? 100
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let waveformData = try self.extractWaveformData(inputPath: inputPath, samplesPerSecond: samplesPerSecond)
                DispatchQueue.main.async {
                    result(waveformData)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "WAVEFORM_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    private func handleIsFormatSupported(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing inputPath", details: nil))
            return
        }
        
        let isSupported = isAudioFormatSupported(inputPath: inputPath)
        result(isSupported)
    }
    
    private func handleGetAudioInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing inputPath", details: nil))
            return
        }
        
        do {
            let audioInfo = try getAudioFileInfo(inputPath: inputPath)
            result(audioInfo)
        } catch {
            result(FlutterError(code: "INFO_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func handleTrimAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String,
              let outputPath = args["outputPath"] as? String,
              let startTimeMs = args["startTimeMs"] as? Int,
              let endTimeMs = args["endTimeMs"] as? Int,
              let format = args["format"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }
        
        guard startTimeMs >= 0 && endTimeMs > startTimeMs else {
            result(FlutterError(code: "INVALID_RANGE", message: "Invalid time range: start=\(startTimeMs), end=\(endTimeMs)", details: nil))
            return
        }
        
        let bitRate = args["bitRate"] as? Int ?? 128000
        let sampleRate = args["sampleRate"] as? Int ?? 44100
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let trimResult = try self.trimAudioFile(
                    inputPath: inputPath,
                    outputPath: outputPath,
                    startTimeMs: startTimeMs,
                    endTimeMs: endTimeMs,
                    format: format,
                    bitRate: bitRate,
                    sampleRate: sampleRate
                )
                
                DispatchQueue.main.async {
                    result(trimResult)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "TRIM_ERROR", message: "Failed to trim audio: \(error.localizedDescription)", details: nil))
                }
            }
        }
    }
    
    private func convertAudioFile(inputPath: String, outputPath: String, format: String, bitRate: Int, sampleRate: Int) throws -> [String: Any] {
        let inputURL = URL(fileURLWithPath: inputPath)
        let outputURL = URL(fileURLWithPath: outputPath)
        
        // Ensure output directory exists
        try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let asset = AVAsset(url: inputURL)
        
        // Get audio track
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            throw NSError(domain: "AudioConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
        }
        
        // Configure audio session
        try configureAudioSession()
        
        // Setup export session
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "AudioConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = format == "aac" ? .m4a : .m4a
        
        // Configure audio settings
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: bitRate
        ]
        
        exportSession.audioOutputSettings = audioSettings
        
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?
        var totalDuration: CMTime = CMTime.zero
        
        // Start progress monitoring
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let progress = Double(exportSession.progress)
            DispatchQueue.main.async {
                self.progressEventSink?(["operation": "convert", "progress": progress])
            }
        }
        
        exportSession.exportAsynchronously {
            timer.invalidate()
            if exportSession.status == .failed {
                exportError = exportSession.error
            }
            totalDuration = asset.duration
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = exportError {
            throw error
        }
        
        guard exportSession.status == .completed else {
            throw NSError(domain: "AudioConverter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Export failed with status: \(exportSession.status.rawValue)"])
        }
        
        let durationMs = Int(CMTimeGetSeconds(totalDuration) * 1000)
        
        return [
            "outputPath": outputPath,
            "durationMs": durationMs,
            "bitRate": bitRate,
            "sampleRate": sampleRate
        ]
    }
    
    private func trimAudioFile(inputPath: String, outputPath: String, startTimeMs: Int, endTimeMs: Int, format: String, bitRate: Int, sampleRate: Int) throws -> [String: Any] {
        let inputURL = URL(fileURLWithPath: inputPath)
        let outputURL = URL(fileURLWithPath: outputPath)
        
        // Use lossless copy if format is "copy"
        if format == "copy" {
            return try trimAudioLossless(inputURL: inputURL, outputURL: outputURL, startTimeMs: startTimeMs, endTimeMs: endTimeMs)
        }
        
        let asset = AVAsset(url: inputURL)
        
        // Get the audio track
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            throw NSError(domain: "AudioConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
        }
        
        // Configure audio session
        try configureAudioSession()
        
        // Create composition for trimming
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        
        let startTime = CMTime(seconds: Double(startTimeMs) / 1000.0, preferredTimescale: 600)
        let endTime = CMTime(seconds: Double(endTimeMs) / 1000.0, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)
        
        // Set up export session
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "AudioConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create export session"])
        }
        
        exportSession.outputURL = outputURL
        
        switch format {
        case "aac", "m4a":
            exportSession.outputFileType = .m4a
        default:
            exportSession.outputFileType = .m4a
        }
        
        // Configure audio settings
        exportSession.audioSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: bitRate
        ]
        
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?
        var totalDuration = CMTime.zero
        
        // Monitor progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let progress = Double(exportSession.progress)
            DispatchQueue.main.async {
                self.progressEventSink?(["operation": "trim", "progress": progress])
            }
        }
        
        exportSession.exportAsynchronously {
            timer.invalidate()
            if exportSession.status == .failed {
                exportError = exportSession.error
            }
            totalDuration = composition.duration
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = exportError {
            throw error
        }
        
        guard exportSession.status == .completed else {
            throw NSError(domain: "AudioConverter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Export failed with status: \(exportSession.status.rawValue)"])
        }
        
        let durationMs = Int(CMTimeGetSeconds(totalDuration) * 1000)
        
        return [
            "outputPath": outputPath,
            "durationMs": durationMs,
            "bitRate": bitRate,
            "sampleRate": sampleRate
        ]
    }
    
    private func trimAudioLossless(inputURL: URL, outputURL: URL, startTimeMs: Int, endTimeMs: Int) throws -> [String: Any] {
        let asset = AVAsset(url: inputURL)
        
        // Get the audio track
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
            throw NSError(domain: "AudioConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
        }
        
        // Create composition for trimming
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        
        let startTime = CMTime(seconds: Double(startTimeMs) / 1000.0, preferredTimescale: 600)
        let endTime = CMTime(seconds: Double(endTimeMs) / 1000.0, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)
        
        // Get original format information
        let formatDescriptions = audioTrack.formatDescriptions
        guard let formatDescription = formatDescriptions.first as? CMAudioFormatDescription else {
            throw NSError(domain: "AudioConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot get audio format description"])
        }
        
        let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)
        let originalSampleRate = Int(audioStreamBasicDescription?.pointee.mSampleRate ?? 44100)
        let originalChannels = Int(audioStreamBasicDescription?.pointee.mChannelsPerFrame ?? 2)
        let formatID = audioStreamBasicDescription?.pointee.mFormatID ?? kAudioFormatMPEG4AAC
        
        // Set up export session with appropriate preset to maintain quality
        let presetName: String
        switch formatID {
        case kAudioFormatMPEGLayer3:
            presetName = AVAssetExportPresetPassthrough // Try to maintain original format
        case kAudioFormatMPEG4AAC:
            presetName = AVAssetExportPresetAppleM4A
        default:
            presetName = AVAssetExportPresetAppleM4A
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: presetName) else {
            throw NSError(domain: "AudioConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create export session for lossless copy"])
        }
        
        exportSession.outputURL = outputURL
        
        // Determine output file type based on original format
        switch formatID {
        case kAudioFormatMPEGLayer3:
            // For MP3, we'll have to use M4A since iOS doesn't support MP3 export
            exportSession.outputFileType = .m4a
        case kAudioFormatMPEG4AAC:
            exportSession.outputFileType = .m4a
        default:
            exportSession.outputFileType = .m4a
        }
        
        // For lossless copy, try to use minimal processing
        if presetName == AVAssetExportPresetPassthrough {
            // Don't set audio settings to maintain original encoding
        } else {
            // Set high-quality audio settings to minimize quality loss
            exportSession.audioSettings = [
                AVFormatIDKey: formatID,
                AVSampleRateKey: originalSampleRate,
                AVNumberOfChannelsKey: originalChannels,
                AVEncoderBitRateKey: 320000 // High bitrate for quality preservation
            ]
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?
        var totalDuration = CMTime.zero
        
        // Monitor progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let progress = Double(exportSession.progress)
            DispatchQueue.main.async {
                self.progressEventSink?(["operation": "trim_lossless", "progress": progress])
            }
        }
        
        exportSession.exportAsynchronously {
            timer.invalidate()
            if exportSession.status == .failed {
                exportError = exportSession.error
            }
            totalDuration = composition.duration
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = exportError {
            throw error
        }
        
        guard exportSession.status == .completed else {
            throw NSError(domain: "AudioConverter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Lossless export failed with status: \(exportSession.status.rawValue)"])
        }
        
        let durationMs = Int(CMTimeGetSeconds(totalDuration) * 1000)
        
        // Estimate original bitrate
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: inputURL.path)
        let fileSize = fileAttributes[.size] as? Int64 ?? 0
        let originalDuration = CMTimeGetSeconds(asset.duration)
        let estimatedBitRate = originalDuration > 0 ? Int((Double(fileSize) * 8) / originalDuration) : 320000
        
        return [
            "outputPath": outputURL.path,
            "durationMs": durationMs,
            "bitRate": estimatedBitRate,
            "sampleRate": originalSampleRate
        ]
    }

    // ...existing code...
}

extension FlutterAudioToolkitPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        progressEventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        progressEventSink = nil
        return nil
    }
}
