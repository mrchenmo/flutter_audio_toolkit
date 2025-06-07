package com.aahanaproduction.flutter_audio_toolkit

import android.content.Context
import android.media.*
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.File
import java.io.IOException
import java.nio.ByteBuffer
import kotlin.math.*

/** FlutterAudioToolkitPlugin */
class FlutterAudioToolkitPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var progressChannel: EventChannel
    private lateinit var context: Context
    private var progressSink: EventChannel.EventSink? = null

    companion object {
        private const val TAG = "FlutterAudioToolkit"
        private const val TIMEOUT_US = 10000L
        private const val SAMPLE_RATE = 44100
        private const val BIT_RATE = 128000
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_audio_toolkit")
        channel.setMethodCallHandler(this)
        
        progressChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_audio_toolkit/progress")
        progressChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                progressSink = events
            }
            override fun onCancel(arguments: Any?) {
                progressSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        progressSink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "convertAudio" -> {
                handleConvertAudio(call, result)
            }
            "extractWaveform" -> {
                handleExtractWaveform(call, result)
            }
            "isFormatSupported" -> {
                handleIsFormatSupported(call, result)
            }
            "getAudioInfo" -> {
                handleGetAudioInfo(call, result)
            }
            "trimAudio" -> {
                handleTrimAudio(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleConvertAudio(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")
        val format = call.argument<String>("format")
        val bitRate = call.argument<Int>("bitRate") ?: BIT_RATE
        val sampleRate = call.argument<Int>("sampleRate") ?: SAMPLE_RATE

        if (inputPath == null || outputPath == null || format == null) {
            result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
            return
        }

        GlobalScope.launch(Dispatchers.IO) {
            try {
                Log.d(TAG, "Starting audio conversion: $inputPath -> $outputPath (format: $format)")
                val convertedData = convertAudio(inputPath, outputPath, format, bitRate, sampleRate)
                Handler(Looper.getMainLooper()).post {
                    result.success(convertedData)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Audio conversion failed", e)
                Handler(Looper.getMainLooper()).post {
                    result.error("CONVERSION_ERROR", "Audio conversion failed: ${e.javaClass.simpleName} - ${e.message}", null)
                }
            }
        }
    }

    private suspend fun convertAudio(
        inputPath: String,
        outputPath: String,
        format: String,
        bitRate: Int,
        sampleRate: Int
    ): Map<String, Any?> = withContext(Dispatchers.IO) {
        
        Log.d(TAG, "Converting audio file: $inputPath -> $outputPath")
        
        val extractor = MediaExtractor()
        val decoder: MediaCodec
        val encoder: MediaCodec  
        val muxer: MediaMuxer

        try {
            // Setup extractor
            extractor.setDataSource(inputPath)
            Log.d(TAG, "Setting data source: $inputPath")

            // Find audio track
            var audioTrackIndex = -1
            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
                Log.d(TAG, "Track $i: MIME = $mime")
                if (mime.startsWith("audio/")) {
                    audioTrackIndex = i
                    Log.d(TAG, "Found audio track at index $i")
                    break
                }
            }

            if (audioTrackIndex == -1) {
                throw IOException("No audio track found in input file")
            }

            val inputFormat = extractor.getTrackFormat(audioTrackIndex)
            extractor.selectTrack(audioTrackIndex)

            // Create decoder
            val inputMime = inputFormat.getString(MediaFormat.KEY_MIME) ?: ""
            Log.d(TAG, "Creating decoder for MIME type: $inputMime")
            decoder = MediaCodec.createDecoderByType(inputMime)
            decoder.configure(inputFormat, null, null, 0)
            decoder.start()

            // Create encoder
            val outputMime = when (format.lowercase()) {
                "aac", "m4a" -> "audio/mp4a-latm"
                "mp3" -> "audio/mpeg"
                else -> throw IllegalArgumentException("Unsupported output format: $format")
            }
            
            Log.d(TAG, "Creating encoder for MIME type: $outputMime")
            encoder = MediaCodec.createEncoderByType(outputMime)
            
            val outputFormat = MediaFormat.createAudioFormat(outputMime, sampleRate, 2).apply {
                setInteger(MediaFormat.KEY_BIT_RATE, bitRate)
                setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            }
            Log.d(TAG, "Configuring encoder with sample rate: $sampleRate, bit rate: $bitRate")
            
            encoder.configure(outputFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            encoder.start()            // Create muxer
            Log.d(TAG, "Creating muxer for output: $outputPath")
            muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)

            val audioData = processAudioData(extractor, decoder, encoder, muxer, inputFormat, outputPath)
            
            Log.d(TAG, "Audio conversion completed successfully")
            audioData
            
        } finally {
            Log.d(TAG, "Cleaning up resources")
            try {
                extractor.release()
            } catch (e: Exception) {
                Log.e(TAG, "Error releasing extractor", e)            }
        }
    }

    private suspend fun processAudioData(
        extractor: MediaExtractor,
        decoder: MediaCodec,
        encoder: MediaCodec,
        muxer: MediaMuxer,
        inputFormat: MediaFormat,
        outputPath: String
    ): Map<String, Any?> = withContext(Dispatchers.IO) {
        val decoderBufferInfo = MediaCodec.BufferInfo()
        val encoderBufferInfo = MediaCodec.BufferInfo()

        var decoderDone = false
        var encoderDone = false
        var muxerStarted = false
        var audioTrackIndex = -1

        val inputDurationUs = inputFormat.getLong(MediaFormat.KEY_DURATION)
        var processedDurationUs = 0L

        while (!encoderDone) {
            // Feed input to decoder
            if (!decoderDone) {
                val inputBufferIndex = decoder.dequeueInputBuffer(TIMEOUT_US)
                if (inputBufferIndex >= 0) {
                    val inputBuffer = decoder.getInputBuffer(inputBufferIndex)
                    if (inputBuffer != null) {
                        val sampleSize = extractor.readSampleData(inputBuffer, 0)
                        
                        if (sampleSize < 0) {
                            decoder.queueInputBuffer(inputBufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            decoderDone = true
                        } else {
                            val presentationTimeUs = extractor.sampleTime
                            decoder.queueInputBuffer(inputBufferIndex, 0, sampleSize, presentationTimeUs, 0)
                            extractor.advance()
                            
                            // Update progress
                            processedDurationUs = presentationTimeUs
                            val progress = if (inputDurationUs > 0) {
                                (processedDurationUs.toDouble() / inputDurationUs.toDouble()).coerceIn(0.0, 1.0)
                            } else 0.0
                            
                            Handler(Looper.getMainLooper()).post {
                                progressSink?.success(mapOf("operation" to "convert", "progress" to progress))
                            }
                        }
                    }
                }
            }

            // Get output from decoder and feed to encoder
            val outputBufferIndex = decoder.dequeueOutputBuffer(decoderBufferInfo, TIMEOUT_US)
            if (outputBufferIndex >= 0) {
                val outputBuffer = decoder.getOutputBuffer(outputBufferIndex)
                if (decoderBufferInfo.size > 0 && outputBuffer != null) {
                    // Feed to encoder
                    val encoderInputIndex = encoder.dequeueInputBuffer(TIMEOUT_US)
                    if (encoderInputIndex >= 0) {                        val encoderInputBuffer = encoder.getInputBuffer(encoderInputIndex)
                        if (encoderInputBuffer != null) {
                            encoderInputBuffer.clear()
                            
                            // Ensure we don't exceed buffer capacity
                            val dataSize = min(decoderBufferInfo.size, encoderInputBuffer.remaining())
                            if (dataSize > 0) {
                                outputBuffer.position(0)
                                outputBuffer.limit(dataSize)
                                encoderInputBuffer.put(outputBuffer)
                            }
                                
                            encoder.queueInputBuffer(
                                encoderInputIndex,
                                0,
                                dataSize,
                                decoderBufferInfo.presentationTimeUs,
                                decoderBufferInfo.flags
                            )
                        }
                    }
                }
                
                decoder.releaseOutputBuffer(outputBufferIndex, false)
                
                if (decoderBufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                    // Signal end of stream to encoder
                    val encoderInputIndex = encoder.dequeueInputBuffer(TIMEOUT_US)
                    if (encoderInputIndex >= 0) {
                        encoder.queueInputBuffer(encoderInputIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                    }
                }
            }

            // Get output from encoder
            val encoderOutputIndex = encoder.dequeueOutputBuffer(encoderBufferInfo, TIMEOUT_US)
            when (encoderOutputIndex) {
                MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    if (!muxerStarted) {
                        audioTrackIndex = muxer.addTrack(encoder.outputFormat)
                        muxer.start()
                        muxerStarted = true
                    }
                }
                MediaCodec.INFO_TRY_AGAIN_LATER -> {
                    // No output available yet
                }
                else -> {
                    if (encoderOutputIndex >= 0) {
                        val encodedData = encoder.getOutputBuffer(encoderOutputIndex)
                        
                        if (encoderBufferInfo.size > 0 && muxerStarted && encodedData != null) {
                            muxer.writeSampleData(audioTrackIndex, encodedData, encoderBufferInfo)
                        }
                        
                        encoder.releaseOutputBuffer(encoderOutputIndex, false)
                        
                        if (encoderBufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                            encoderDone = true
                        }
                    }
                }
            }
        }

        // Clean up codecs
        try {
            decoder.stop()
            decoder.release()
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing decoder", e)
        }
        
        try {
            encoder.stop()
            encoder.release()
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing encoder", e)
        }
          try {
            muxer.stop()
            muxer.release()        } catch (e: Exception) {
            Log.e(TAG, "Error releasing muxer", e)
        }
        
        val durationMs = (inputDurationUs / 1000).toInt()
        
        // Verify file was created
        val outputFile = File(outputPath)
        if (outputFile.exists()) {
            Log.d(TAG, "Converted file created successfully: $outputPath (size: ${outputFile.length()} bytes)")
        } else {
            Log.e(TAG, "Converted file was not created: $outputPath")
        }
          Handler(Looper.getMainLooper()).post {
            progressSink?.success(mapOf("operation" to "convert", "progress" to 1.0))
        }

        mapOf(
            "outputPath" to outputPath,
            "durationMs" to durationMs,
            "bitRate" to BIT_RATE,
            "sampleRate" to SAMPLE_RATE        )
    }
    
    // Waveform extraction implementation
    private fun handleExtractWaveform(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        val samplesPerSecond = call.argument<Int>("samplesPerSecond") ?: 100

        if (inputPath == null) {
            result.error("INVALID_ARGUMENTS", "Missing inputPath", null)
            return
        }

        val inputFile = File(inputPath)
        if (!inputFile.exists()) {
            result.error("FILE_NOT_FOUND", "Input file does not exist: $inputPath", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val waveformData = extractWaveformData(inputPath, samplesPerSecond)
                
                Handler(Looper.getMainLooper()).post {
                    result.success(waveformData)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error extracting waveform", e)
                Handler(Looper.getMainLooper()).post {
                    result.error("EXTRACTION_FAILED", "Failed to extract waveform: ${e.message}", null)
                }
            }
        }
    }

    private fun handleIsFormatSupported(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        if (inputPath == null) {
            result.error("INVALID_ARGUMENTS", "Missing inputPath", null)
            return
        }
        
        // Basic format check - can be enhanced later
        val isSupported = inputPath.lowercase().let {
            it.endsWith(".mp3") || it.endsWith(".wav") || it.endsWith(".m4a") || it.endsWith(".aac")
        }
        result.success(isSupported)
    }    private fun handleGetAudioInfo(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        if (inputPath == null) {
            result.error("INVALID_ARGUMENTS", "Missing inputPath", null)
            return
        }

        GlobalScope.launch(Dispatchers.IO) {
            try {
                val audioInfo = getAudioFileInfo(inputPath)
                Handler(Looper.getMainLooper()).post {
                    result.success(audioInfo)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get audio info", e)
                Handler(Looper.getMainLooper()).post {
                    result.error("AUDIO_INFO_ERROR", "Failed to get audio info: ${e.message}", null)
                }
            }
        }
    }    private fun getAudioFileInfo(inputPath: String): Map<String, Any?> {
        val extractor = MediaExtractor()
        val file = File(inputPath)
        
        Log.d(TAG, "Getting audio info for: $inputPath")
        
        // First check if file exists and is readable
        if (!file.exists()) {
            Log.e(TAG, "File does not exist: $inputPath")
            return mapOf(
                "isValid" to false,
                "error" to "File does not exist",
                "details" to "The selected file could not be found at the specified path."
            )
        }
        
        if (!file.canRead()) {
            Log.e(TAG, "File is not readable: $inputPath")
            return mapOf(
                "isValid" to false,
                "error" to "File is not readable",
                "details" to "Permission denied or file is corrupted."
            )
        }
        
        val fileSize = file.length()
        if (fileSize == 0L) {
            Log.e(TAG, "File is empty: $inputPath")
            return mapOf(
                "isValid" to false,
                "error" to "File is empty",
                "details" to "The selected file has no content."
            )
        }
        
        Log.d(TAG, "File exists and readable, size: $fileSize bytes")
        
        try {
            extractor.setDataSource(inputPath)
            Log.d(TAG, "MediaExtractor setDataSource successful")
            
            val trackCount = extractor.trackCount
            Log.d(TAG, "Total tracks in file: $trackCount")
            
            if (trackCount == 0) {
                return mapOf(
                    "isValid" to false,
                    "error" to "No tracks found",
                    "details" to "The file contains no audio or video tracks. It may be corrupted or in an unsupported format."
                )
            }
            
            // Find audio track and log all tracks for debugging
            var audioTrackIndex = -1
            var audioFormat: MediaFormat? = null
            val trackInfo = mutableListOf<String>()
            
            for (i in 0 until trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: "unknown"
                trackInfo.add("Track $i: $mime")
                Log.d(TAG, "Track $i: MIME = $mime")
                
                if (mime.startsWith("audio/") && audioTrackIndex == -1) {
                    audioTrackIndex = i
                    audioFormat = format
                    Log.d(TAG, "Found first audio track at index $i")
                }
            }
            
            if (audioTrackIndex == -1 || audioFormat == null) {
                val supportedFormats = "mp3, m4a, aac, wav, ogg"
                return mapOf(
                    "isValid" to false,
                    "error" to "No audio track found",
                    "details" to "The file contains no audio tracks. Supported formats: $supportedFormats. Found tracks: ${trackInfo.joinToString(", ")}",
                    "foundTracks" to trackInfo
                )
            }
            
            // Extract audio information
            val mime = audioFormat.getString(MediaFormat.KEY_MIME) ?: "unknown"
            Log.d(TAG, "Audio format MIME: $mime")            // Check if format is supported for trimming
            val supportedForTrimming = when {
                mime.equals("audio/mpeg", ignoreCase = true) -> true  // MP3
                mime.equals("audio/mp3", ignoreCase = true) -> true   // Alternative MP3 MIME
                mime.contains("mp3") -> true                          // Fallback for mp3
                mime.equals("audio/aac", ignoreCase = true) -> true   // AAC
                mime.equals("audio/mp4", ignoreCase = true) -> true   // M4A/MP4
                mime.equals("audio/mp4a-latm", ignoreCase = true) -> true // M4A variant
                mime.contains("aac") -> true                          // AAC fallback
                mime.contains("mp4") -> true                          // MP4 fallback
                mime.contains("m4a") -> true                          // M4A fallback
                mime.equals("audio/wav", ignoreCase = true) -> true   // WAV
                mime.equals("audio/wave", ignoreCase = true) -> true  // WAV variant
                mime.equals("audio/x-wav", ignoreCase = true) -> true // WAV variant
                mime.contains("wav") -> true                          // WAV fallback
                mime.equals("audio/ogg", ignoreCase = true) -> true   // OGG
                mime.equals("audio/vorbis", ignoreCase = true) -> true // OGG Vorbis
                mime.contains("ogg") -> true                          // OGG fallback
                else -> false
            }
            
            // Check if format supports lossless trimming (direct stream copy)
            val supportedForLosslessTrimming = when {
                mime.equals("audio/mp4", ignoreCase = true) -> true   // M4A/MP4
                mime.equals("audio/mp4a-latm", ignoreCase = true) -> true // M4A variant
                mime.equals("audio/aac", ignoreCase = true) -> true   // AAC in container
                mime.contains("mp4") -> true                          // MP4 fallback
                mime.contains("m4a") -> true                          // M4A fallback
                else -> false  // MP3, WAV, OGG require conversion for trimming
            }
            
            val durationUs = audioFormat.getLong(MediaFormat.KEY_DURATION)
            val durationMs = durationUs / 1000
            val sampleRate = audioFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val channelCount = audioFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            val bitRate = if (audioFormat.containsKey(MediaFormat.KEY_BIT_RATE)) {
                audioFormat.getInteger(MediaFormat.KEY_BIT_RATE)
            } else {
                // Estimate bit rate from file size and duration
                val durationSeconds = durationUs / 1_000_000.0
                if (durationSeconds > 0) {
                    ((fileSize * 8) / durationSeconds).toInt()
                } else {
                    0
                }
            }
              Log.d(TAG, "Audio info extracted - Duration: ${durationMs}ms, SampleRate: $sampleRate, Channels: $channelCount, BitRate: $bitRate")
            Log.d(TAG, "MIME type: $mime, Supported for trimming: $supportedForTrimming")
              // Add diagnostic information about format support
            val formatDiagnostics = when {
                mime.equals("audio/mpeg", ignoreCase = true) -> "MP3 format detected (audio/mpeg) - Requires conversion for trimming"
                mime.equals("audio/mp3", ignoreCase = true) -> "MP3 format detected (audio/mp3) - Requires conversion for trimming"
                mime.equals("audio/aac", ignoreCase = true) -> "AAC format detected - Supports lossless trimming"
                mime.equals("audio/mp4", ignoreCase = true) -> "M4A/MP4 format detected - Supports lossless trimming"
                mime.equals("audio/mp4a-latm", ignoreCase = true) -> "M4A format detected - Supports lossless trimming"
                mime.equals("audio/wav", ignoreCase = true) -> "WAV format detected - Requires conversion for trimming"
                mime.equals("audio/wave", ignoreCase = true) -> "WAV format detected - Requires conversion for trimming"
                mime.equals("audio/x-wav", ignoreCase = true) -> "WAV format detected - Requires conversion for trimming"
                mime.equals("audio/ogg", ignoreCase = true) -> "OGG format detected - Requires conversion for trimming"
                mime.equals("audio/vorbis", ignoreCase = true) -> "OGG Vorbis format detected - Requires conversion for trimming"
                else -> "Unknown/unsupported format: $mime - May require conversion"
            }

            return mapOf(
                "isValid" to true,
                "durationMs" to durationMs.toInt(),
                "sampleRate" to sampleRate,
                "channels" to channelCount,
                "bitRate" to bitRate,
                "mime" to mime,  // Changed from mimeType to mime to match UI
                "trackIndex" to audioTrackIndex,
                "fileSize" to fileSize,
                "supportedForTrimming" to supportedForTrimming,
                "supportedForConversion" to supportedForTrimming,
                "supportedForWaveform" to supportedForTrimming,
                "supportedForLosslessTrimming" to supportedForLosslessTrimming,
                "formatDiagnostics" to formatDiagnostics,
                "foundTracks" to trackInfo
            )
            
        } catch (e: IOException) {
            Log.e(TAG, "IOException while reading file", e)
            return mapOf(
                "isValid" to false,
                "error" to "Cannot read audio file",
                "details" to "The file may be corrupted, encrypted, or in an unsupported format. Error: ${e.message}"
            )
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "IllegalArgumentException while reading file", e)
            return mapOf(
                "isValid" to false,
                "error" to "Invalid audio format",
                "details" to "The file format is not supported by Android MediaExtractor. Error: ${e.message}"
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while reading file", e)
            return mapOf(
                "isValid" to false,
                "error" to "Unexpected error",
                "details" to "An unexpected error occurred while analyzing the file: ${e.javaClass.simpleName} - ${e.message}"
            )
        } finally {
            try {
                extractor.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing MediaExtractor", e)
            }
        }
    }    private fun handleTrimAudio(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath") 
        val startTimeMs = call.argument<Int>("startTimeMs")
        val endTimeMs = call.argument<Int>("endTimeMs")
        val format = call.argument<String>("format")
        val bitRate = call.argument<Int>("bitRate") ?: BIT_RATE
        val sampleRate = call.argument<Int>("sampleRate") ?: SAMPLE_RATE

        if (inputPath == null || outputPath == null || startTimeMs == null || endTimeMs == null || format == null) {
            result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
            return
        }

        if (startTimeMs >= endTimeMs) {
            result.error("INVALID_RANGE", "Start time must be less than end time", null)
            return
        }

        GlobalScope.launch(Dispatchers.IO) {
            try {
                Log.d(TAG, "Starting audio trimming: $inputPath -> $outputPath (${startTimeMs}ms to ${endTimeMs}ms)")
                val trimmedData = trimAudio(inputPath, outputPath, startTimeMs, endTimeMs, format, bitRate, sampleRate)
                Handler(Looper.getMainLooper()).post {
                    result.success(trimmedData)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Audio trimming failed", e)
                Handler(Looper.getMainLooper()).post {
                    result.error("TRIM_ERROR", "Audio trimming failed: ${e.javaClass.simpleName} - ${e.message}", null)
                }
            }
        }
    }    private suspend fun trimAudio(
        inputPath: String,
        outputPath: String,
        startTimeMs: Int,
        endTimeMs: Int,
        format: String,
        bitRate: Int,
        sampleRate: Int
    ): Map<String, Any?> = withContext(Dispatchers.IO) {
        
        Log.d(TAG, "Trimming audio file: $inputPath -> $outputPath (${startTimeMs}ms to ${endTimeMs}ms), format: $format")        // Use lossless copy if format is "copy"
        if (format == "copy") {
            return@withContext trimAudioLossless(inputPath, outputPath, startTimeMs, endTimeMs)
        }
        
        val startTimeUs = startTimeMs * 1000L
        val endTimeUs = endTimeMs * 1000L
        val durationUs = endTimeUs - startTimeUs
        
        val extractor = MediaExtractor()
        val decoder: MediaCodec
        val encoder: MediaCodec
        val muxer: MediaMuxer

        try {
            // Setup extractor
            extractor.setDataSource(inputPath)
            
            // Find audio track
            var audioTrackIndex = -1
            var inputFormat: MediaFormat? = null
            
            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME)
                if (mime?.startsWith("audio/") == true) {
                    audioTrackIndex = i
                    inputFormat = format
                    break
                }
            }
            
            if (audioTrackIndex == -1 || inputFormat == null) {
                throw IllegalArgumentException("No audio track found in input file")
            }
            
            extractor.selectTrack(audioTrackIndex)
            extractor.seekTo(startTimeUs, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
            
            // Setup decoder
            val inputMime = inputFormat.getString(MediaFormat.KEY_MIME)!!
            decoder = MediaCodec.createDecoderByType(inputMime)
            decoder.configure(inputFormat, null, null, 0)
            decoder.start()
            
            // Setup encoder
            val outputMime = when (format) {
                "aac" -> MediaFormat.MIMETYPE_AUDIO_AAC
                "m4a" -> MediaFormat.MIMETYPE_AUDIO_AAC
                else -> MediaFormat.MIMETYPE_AUDIO_AAC
            }
            
            val encoderFormat = MediaFormat.createAudioFormat(outputMime, sampleRate, 2).apply {
                setInteger(MediaFormat.KEY_BIT_RATE, bitRate)
                setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            }
            
            encoder = MediaCodec.createEncoderByType(outputMime)
            encoder.configure(encoderFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            encoder.start()
            
            // Setup muxer
            File(outputPath).parentFile?.mkdirs()
            muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
              // Process audio data with time range
            processAudioDataWithTimeRange(extractor, decoder, encoder, muxer, inputFormat, outputPath, startTimeUs, endTimeUs)
            
            Log.d(TAG, "Audio trimming completed successfully")
              // Verify file was created
            val outputFile = File(outputPath)
            if (outputFile.exists()) {
                Log.d(TAG, "Trimmed file created successfully: $outputPath (size: ${outputFile.length()} bytes)")
            } else {
                Log.e(TAG, "Trimmed file was not created: $outputPath")
            }
            
            mapOf(
                "outputPath" to outputPath,
                "durationMs" to (durationUs / 1000).toInt(),
                "bitRate" to bitRate,
                "sampleRate" to sampleRate
            )
            
        } finally {
            try {
                extractor.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing MediaExtractor", e)
            }
        }
    }

    private fun processAudioDataWithTimeRange(
        extractor: MediaExtractor,
        decoder: MediaCodec,
        encoder: MediaCodec,
        muxer: MediaMuxer,
        inputFormat: MediaFormat,
        outputPath: String,
        startTimeUs: Long,
        endTimeUs: Long
    ) {
        var outputTrackIndex = -1
        var muxerStarted = false
        var totalBytesProcessed = 0L
        val bufferInfo = MediaCodec.BufferInfo()
        
        try {
            // Decode and encode loop
            var inputDone = false
            var outputDone = false
            
            while (!outputDone) {
                // Feed input to decoder
                if (!inputDone) {
                    val inputBufferIndex = decoder.dequeueInputBuffer(TIMEOUT_US)
                    if (inputBufferIndex >= 0) {
                        val inputBuffer = decoder.getInputBuffer(inputBufferIndex)!!
                        val sampleSize = extractor.readSampleData(inputBuffer, 0)
                        val presentationTimeUs = extractor.sampleTime
                        
                        if (sampleSize < 0 || presentationTimeUs >= endTimeUs) {
                            decoder.queueInputBuffer(inputBufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else if (presentationTimeUs >= startTimeUs) {
                            // Adjust timestamp to start from 0
                            val adjustedTimeUs = presentationTimeUs - startTimeUs
                            decoder.queueInputBuffer(inputBufferIndex, 0, sampleSize, adjustedTimeUs, 0)
                            extractor.advance()
                        } else {
                            // Skip samples before start time
                            decoder.queueInputBuffer(inputBufferIndex, 0, 0, 0, 0)
                            extractor.advance()
                        }
                    }
                }
                
                // Get output from decoder and feed to encoder
                val outputBufferIndex = decoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_US)
                if (outputBufferIndex >= 0) {
                    val outputBuffer = decoder.getOutputBuffer(outputBufferIndex)!!
                      if (bufferInfo.size > 0) {
                        // Feed to encoder
                        val encoderInputIndex = encoder.dequeueInputBuffer(TIMEOUT_US)
                        if (encoderInputIndex >= 0) {
                            val encoderInputBuffer = encoder.getInputBuffer(encoderInputIndex)!!
                            encoderInputBuffer.clear()
                            
                            // Ensure we don't exceed buffer capacity
                            val dataSize = min(bufferInfo.size, encoderInputBuffer.remaining())
                            if (dataSize > 0) {
                                outputBuffer.position(0)
                                outputBuffer.limit(dataSize)
                                encoderInputBuffer.put(outputBuffer)
                            }
                            
                            encoder.queueInputBuffer(
                                encoderInputIndex,
                                0,
                                dataSize,
                                bufferInfo.presentationTimeUs,
                                bufferInfo.flags
                            )
                        }
                    }
                    
                    decoder.releaseOutputBuffer(outputBufferIndex, false)
                    
                    if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                        // Signal end of stream to encoder
                        val encoderInputIndex = encoder.dequeueInputBuffer(TIMEOUT_US)
                        if (encoderInputIndex >= 0) {
                            encoder.queueInputBuffer(encoderInputIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                        }
                    }
                }
                
                // Get output from encoder and write to muxer
                val encoderOutputIndex = encoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_US)
                when (encoderOutputIndex) {
                    MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        if (!muxerStarted) {
                            val outputFormat = encoder.outputFormat
                            outputTrackIndex = muxer.addTrack(outputFormat)
                            muxer.start()
                            muxerStarted = true
                        }
                    }
                    MediaCodec.INFO_TRY_AGAIN_LATER -> {
                        // No output available yet
                    }
                    else -> {
                        if (encoderOutputIndex >= 0) {
                            val encodedData = encoder.getOutputBuffer(encoderOutputIndex)!!
                            
                            if (bufferInfo.size > 0 && muxerStarted) {
                                encodedData.position(bufferInfo.offset)
                                encodedData.limit(bufferInfo.offset + bufferInfo.size)
                                muxer.writeSampleData(outputTrackIndex, encodedData, bufferInfo)
                                totalBytesProcessed += bufferInfo.size
                            }
                            
                            encoder.releaseOutputBuffer(encoderOutputIndex, false)
                            
                            if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                                outputDone = true
                            }
                        }
                    }                }
            }
        } finally {
            try {
                decoder.stop()
                decoder.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing decoder", e)
            }
            
            try {
                encoder.stop()
                encoder.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing encoder", e)
            }
            
            try {
                if (muxerStarted) {
                    muxer.stop()
                }
                muxer.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing muxer", e)
            }

            try {
                extractor.release()            } catch (e: Exception) {
                Log.w(TAG, "Error releasing extractor", e)
            }
        }
    }

    /**
     * Lossless audio trimming that preserves the original format
     * Uses MediaExtractor and MediaMuxer to copy the stream directly without decode/encode
     */
    private suspend fun trimAudioLossless(
        inputPath: String,
        outputPath: String,
        startTimeMs: Int,
        endTimeMs: Int
    ): Map<String, Any?> = withContext(Dispatchers.IO) {
        
        Log.d(TAG, "Starting lossless audio trimming: $inputPath -> $outputPath (${startTimeMs}ms to ${endTimeMs}ms)")
        
        val startTimeUs = startTimeMs * 1000L
        val endTimeUs = endTimeMs * 1000L
        val durationUs = endTimeUs - startTimeUs
        
        val extractor = MediaExtractor()
        var muxer: MediaMuxer? = null
        var audioTrackIndex = -1
        var outputTrackIndex = -1
        var totalBytesProcessed = 0L
        
        try {
            // Setup extractor
            extractor.setDataSource(inputPath)
            Log.d(TAG, "Lossless trim: Input file has ${extractor.trackCount} tracks")
            
            // Find audio track and get its format
            var audioFormat: MediaFormat? = null
            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME)
                Log.d(TAG, "Track $i: MIME = $mime")
                if (mime?.startsWith("audio/") == true) {
                    audioTrackIndex = i
                    audioFormat = format
                    Log.d(TAG, "Found audio track at index $i with format: $mime")
                    break
                }
            }
            
            if (audioTrackIndex == -1 || audioFormat == null) {
                throw IllegalArgumentException("No audio track found in input file")
            }
              // Get original file extension for output
            val inputFile = File(inputPath)
            val originalExtension = inputFile.extension.lowercase()
            
            // Determine output format based on original file
            val outputFormat = when (originalExtension) {
                "mp3" -> {
                    // MP3 files cannot be directly muxed - they need conversion
                    Log.w(TAG, "MP3 lossless trimming not directly supported by MediaMuxer. Consider using conversion instead.")
                    throw IllegalArgumentException("MP3 files require conversion for trimming. Use AAC or M4A output format instead.")
                }
                "m4a", "aac", "mp4" -> MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4
                "wav" -> {
                    Log.w(TAG, "WAV lossless trimming may not preserve original format. Consider using conversion.")
                    MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4 
                }
                "ogg" -> {
                    Log.w(TAG, "OGG lossless trimming may not preserve original format. Consider using conversion.")
                    MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4
                }
                else -> {
                    Log.w(TAG, "Unknown format $originalExtension, using MP4 container")
                    MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4
                }
            }
            
            // Setup muxer
            muxer = MediaMuxer(outputPath, outputFormat)
            outputTrackIndex = muxer.addTrack(audioFormat)
            
            // Select the audio track and seek to start time
            extractor.selectTrack(audioTrackIndex)
            extractor.seekTo(startTimeUs, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
            
            // Get the actual seek position (may be different from requested due to sync frames)
            val actualStartTimeUs = extractor.sampleTime
            Log.d(TAG, "Requested start: ${startTimeUs}μs, Actual start: ${actualStartTimeUs}μs")
            
            // Start muxer
            muxer.start()
            
            // Copy samples within the time range
            val bufferInfo = MediaCodec.BufferInfo()
            val buffer = ByteBuffer.allocate(1024 * 1024) // 1MB buffer
            var samplesProcessed = 0
            
            while (true) {
                val sampleTime = extractor.sampleTime
                
                // Check if we've reached the end time
                if (sampleTime < 0 || sampleTime >= endTimeUs) {
                    Log.d(TAG, "Reached end time or end of stream at ${sampleTime}μs")
                    break
                }
                
                // Read sample data
                buffer.clear()
                val sampleSize = extractor.readSampleData(buffer, 0)
                
                if (sampleSize < 0) {
                    Log.d(TAG, "No more samples available")
                    break
                }
                
                // Only copy samples within our target range
                if (sampleTime >= startTimeUs) {
                    // Adjust timestamp to start from 0
                    val adjustedTimeUs = sampleTime - actualStartTimeUs
                    
                    bufferInfo.presentationTimeUs = adjustedTimeUs
                    bufferInfo.size = sampleSize
                    bufferInfo.offset = 0
                    bufferInfo.flags = extractor.sampleFlags
                    
                    // Write sample to output
                    buffer.rewind()
                    muxer.writeSampleData(outputTrackIndex, buffer, bufferInfo)
                    totalBytesProcessed += sampleSize
                    samplesProcessed++
                    
                    // Update progress
                    val progress = ((sampleTime - startTimeUs).toDouble() / durationUs.toDouble()).coerceIn(0.0, 1.0)
                    Handler(Looper.getMainLooper()).post {
                        progressSink?.success(progress)
                    }
                }
                
                // Advance to next sample
                if (!extractor.advance()) {
                    Log.d(TAG, "No more samples to advance")
                    break
                }
            }
            
            Log.d(TAG, "Lossless trim completed: $samplesProcessed samples, $totalBytesProcessed bytes")
            
            // Verify output file was created
            val outputFile = File(outputPath)
            if (!outputFile.exists()) {
                Log.e(TAG, "Lossless trimmed file was not created: $outputPath")
            } else {
                Log.d(TAG, "Lossless trimmed file created successfully: $outputPath (${outputFile.length()} bytes)")
            }
              // Get audio properties from original format
            val originalSampleRate = audioFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val originalBitRate = if (audioFormat.containsKey(MediaFormat.KEY_BIT_RATE)) {
                audioFormat.getInteger(MediaFormat.KEY_BIT_RATE)            } else {
                // Estimate bitrate based on file size and duration
                val fileSizeBytes = File(inputPath).length()
                val durationSeconds = (extractor.getTrackFormat(audioTrackIndex).getLong(MediaFormat.KEY_DURATION) / 1_000_000.0)
                ((fileSizeBytes * 8) / durationSeconds).toInt()
            }
            
            mapOf(
                "outputPath" to outputPath,
                "durationMs" to (durationUs / 1000).toInt(),
                "bitRate" to originalBitRate,
                "sampleRate" to originalSampleRate
            )
            
        } finally {
            try {
                muxer?.stop()
                muxer?.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing MediaMuxer", e)
            }
            
            try {
                extractor.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing MediaExtractor", e)
            }
        }
    }

    private fun extractWaveformData(inputPath: String, samplesPerSecond: Int): Map<String, Any> {
        val extractor = MediaExtractor()
        var decoder: MediaCodec? = null
        val amplitudes = mutableListOf<Double>()
        
        try {
            extractor.setDataSource(inputPath)
            
            // Find audio track
            var audioTrackIndex = -1
            var inputFormat: MediaFormat? = null
            
            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME)
                if (mime?.startsWith("audio/") == true) {
                    audioTrackIndex = i
                    inputFormat = format
                    break
                }
            }
            
            if (audioTrackIndex == -1 || inputFormat == null) {
                throw IllegalArgumentException("No audio track found in input file")
            }
            
            // Extract audio information
            val durationUs = inputFormat.getLong(MediaFormat.KEY_DURATION)
            val durationMs = (durationUs / 1000).toInt()
            val sampleRate = inputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val channels = inputFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            
            // Select and configure decoder
            extractor.selectTrack(audioTrackIndex)
            val mime = inputFormat.getString(MediaFormat.KEY_MIME)!!
            decoder = MediaCodec.createDecoderByType(mime)
            
            // Configure output format for raw PCM
            val outputFormat = MediaFormat.createAudioFormat(MediaFormat.MIMETYPE_AUDIO_RAW, sampleRate, channels)
            outputFormat.setInteger(MediaFormat.KEY_PCM_ENCODING, AudioFormat.ENCODING_PCM_16BIT)
            
            decoder.configure(inputFormat, null, null, 0)
            decoder.start()
            
            val bufferInfo = MediaCodec.BufferInfo()
            var inputDone = false
            var outputDone = false
            
            // Calculate sample interval
            val totalSamples = (durationMs * samplesPerSecond) / 1000
            val samplesPerBatch = max(1, sampleRate / samplesPerSecond)
            var sampleCount = 0
            var currentBatchSamples = 0
            var batchMaxAmplitude = 0.0
            
            while (!outputDone) {
                // Feed input to decoder
                if (!inputDone) {
                    val inputIndex = decoder.dequeueInputBuffer(TIMEOUT_US)
                    if (inputIndex >= 0) {
                        val inputBuffer = decoder.getInputBuffer(inputIndex)!!
                        val sampleSize = extractor.readSampleData(inputBuffer, 0)
                        
                        if (sampleSize < 0) {
                            decoder.queueInputBuffer(inputIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            val presentationTimeUs = extractor.sampleTime
                            decoder.queueInputBuffer(inputIndex, 0, sampleSize, presentationTimeUs, 0)
                            extractor.advance()
                              // Report progress
                            val progress = (presentationTimeUs.toDouble() / durationUs).coerceIn(0.0, 1.0)
                            Handler(Looper.getMainLooper()).post {
                                progressSink?.success(mapOf("operation" to "extract", "progress" to progress))
                            }
                        }
                    }
                }
                
                // Get output from decoder
                val outputIndex = decoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_US)
                when {
                    outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        // Output format changed
                    }
                    outputIndex >= 0 -> {
                        val outputBuffer = decoder.getOutputBuffer(outputIndex)!!
                        
                        if (bufferInfo.size > 0) {
                            // Process PCM data to extract amplitudes
                            val pcmData = ByteArray(bufferInfo.size)
                            outputBuffer.get(pcmData)
                            
                            // Convert bytes to 16-bit samples and calculate amplitude
                            for (i in 0 until pcmData.size step 2) {
                                if (i + 1 < pcmData.size) {
                                    val sample = ((pcmData[i + 1].toInt() shl 8) or (pcmData[i].toInt() and 0xFF)).toShort()
                                    val amplitude = abs(sample.toDouble()) / 32768.0 // Normalize to 0.0-1.0
                                    
                                    batchMaxAmplitude = max(batchMaxAmplitude, amplitude)
                                    currentBatchSamples++
                                    
                                    if (currentBatchSamples >= samplesPerBatch) {
                                        amplitudes.add(batchMaxAmplitude)
                                        batchMaxAmplitude = 0.0
                                        currentBatchSamples = 0
                                        sampleCount++
                                    }
                                }
                            }
                        }
                        
                        decoder.releaseOutputBuffer(outputIndex, false)
                        
                        if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                            outputDone = true
                        }
                    }
                }
            }
            
            // Add final batch if needed
            if (currentBatchSamples > 0) {
                amplitudes.add(batchMaxAmplitude)
            }
            
            return mapOf(
                "amplitudes" to amplitudes,
                "sampleRate" to sampleRate,
                "durationMs" to durationMs,
                "channels" to channels
            )
            
        } finally {
            try {
                decoder?.stop()
                decoder?.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing decoder", e)
            }
            
            try {
                extractor.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing extractor", e)
            }
        }
    }
}
