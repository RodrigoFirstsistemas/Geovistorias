package br.com.sistema_vistorias

import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TerminalPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var printer: BasePrinter
    private lateinit var nfcReader: BaseNfcReader

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "br.com.sistema_vistorias/terminal_sdk")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        initializeDevices()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initializeDevices() {
        val model = getTerminalModel()
        printer = when {
            model.startsWith("GPOS") -> GertecPrinter(context)
            model.startsWith("L") -> ElginPrinter(context)
            model.startsWith("P2") || model.startsWith("A8") -> PaxPrinter(context)
            else -> DummyPrinter()
        }

        nfcReader = when {
            model.startsWith("GPOS") -> GertecNfcReader(context)
            model.startsWith("L") -> ElginNfcReader(context)
            model.startsWith("P2") || model.startsWith("A8") -> PaxNfcReader(context)
            else -> DummyNfcReader()
        }
    }

    private fun getTerminalModel(): String {
        return when (Build.MODEL.toUpperCase()) {
            "GPOS720" -> "GPOS720"
            "GPOS780" -> "GPOS780"
            "L300" -> "L300"
            "L400" -> "L400"
            "P2" -> "P2"
            "P2MINI" -> "P2MINI"
            "A8GPOS700X" -> "A8GPOS700X"
            else -> "UNKNOWN"
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getTerminalInfo" -> getTerminalInfo(result)
            "getPrinterStatus" -> getPrinterStatus(result)
            "printText" -> printText(call, result)
            "printQrCode" -> printQrCode(call, result)
            "cutPaper" -> cutPaper(result)
            "feedPaper" -> feedPaper(call, result)
            "readNfc" -> readNfc(result)
            else -> result.notImplemented()
        }
    }

    private fun getTerminalInfo(result: MethodChannel.Result) {
        try {
            val model = getTerminalModel()
            val info = mapOf(
                "model" to model,
                "hasPrinter" to printer.isAvailable(),
                "hasNfc" to nfcReader.isAvailable()
            )
            result.success(info)
        } catch (e: Exception) {
            result.error("TERMINAL_ERROR", e.message, null)
        }
    }

    private fun getPrinterStatus(result: MethodChannel.Result) {
        try {
            val status = printer.getStatus()
            result.success(status)
        } catch (e: Exception) {
            result.error("PRINTER_ERROR", e.message, null)
        }
    }

    private fun printText(call: MethodCall, result: MethodChannel.Result) {
        val text = call.argument<String>("text") ?: run {
            result.error("INVALID_ARGUMENT", "Texto é obrigatório", null)
            return
        }
        val bold = call.argument<Boolean>("bold") ?: false
        val doubleWidth = call.argument<Boolean>("doubleWidth") ?: false
        val doubleHeight = call.argument<Boolean>("doubleHeight") ?: false
        val center = call.argument<Boolean>("center") ?: false

        try {
            printer.printText(text, bold, doubleWidth, doubleHeight, center)
            result.success(true)
        } catch (e: Exception) {
            result.error("PRINT_ERROR", e.message, null)
        }
    }

    private fun printQrCode(call: MethodCall, result: MethodChannel.Result) {
        val data = call.argument<String>("data") ?: run {
            result.error("INVALID_ARGUMENT", "Dados do QR Code são obrigatórios", null)
            return
        }

        try {
            printer.printQrCode(data)
            result.success(true)
        } catch (e: Exception) {
            result.error("PRINT_ERROR", e.message, null)
        }
    }

    private fun cutPaper(result: MethodChannel.Result) {
        try {
            printer.cutPaper()
            result.success(true)
        } catch (e: Exception) {
            result.error("PRINT_ERROR", e.message, null)
        }
    }

    private fun feedPaper(call: MethodCall, result: MethodChannel.Result) {
        val lines = call.argument<Int>("lines") ?: 1

        try {
            printer.feedPaper(lines)
            result.success(true)
        } catch (e: Exception) {
            result.error("PRINT_ERROR", e.message, null)
        }
    }

    private fun readNfc(result: MethodChannel.Result) {
        try {
            val nfcData = nfcReader.readCard()
            result.success(nfcData)
        } catch (e: Exception) {
            result.error("NFC_ERROR", e.message, null)
        }
    }
}

// Interfaces base
interface BasePrinter {
    fun isAvailable(): Boolean
    fun getStatus(): Map<String, Any>
    fun printText(text: String, bold: Boolean = false, doubleWidth: Boolean = false, doubleHeight: Boolean = false, center: Boolean = false)
    fun printQrCode(data: String)
    fun cutPaper()
    fun feedPaper(lines: Int)
}

interface BaseNfcReader {
    fun isAvailable(): Boolean
    fun readCard(): String?
}

// Implementações específicas para cada fabricante
class GertecPrinter(private val context: Context) : BasePrinter {
    override fun isAvailable() = true
    override fun getStatus() = mapOf("status" to "ok")
    override fun printText(text: String, bold: Boolean, doubleWidth: Boolean, doubleHeight: Boolean, center: Boolean) {
        // Implementar usando SDK Gertec
    }
    override fun printQrCode(data: String) {
        // Implementar usando SDK Gertec
    }
    override fun cutPaper() {
        // Implementar usando SDK Gertec
    }
    override fun feedPaper(lines: Int) {
        // Implementar usando SDK Gertec
    }
}

class ElginPrinter(private val context: Context) : BasePrinter {
    override fun isAvailable() = true
    override fun getStatus() = mapOf("status" to "ok")
    override fun printText(text: String, bold: Boolean, doubleWidth: Boolean, doubleHeight: Boolean, center: Boolean) {
        // Implementar usando SDK Elgin
    }
    override fun printQrCode(data: String) {
        // Implementar usando SDK Elgin
    }
    override fun cutPaper() {
        // Implementar usando SDK Elgin
    }
    override fun feedPaper(lines: Int) {
        // Implementar usando SDK Elgin
    }
}

class PaxPrinter(private val context: Context) : BasePrinter {
    override fun isAvailable() = true
    override fun getStatus() = mapOf("status" to "ok")
    override fun printText(text: String, bold: Boolean, doubleWidth: Boolean, doubleHeight: Boolean, center: Boolean) {
        // Implementar usando SDK PAX
    }
    override fun printQrCode(data: String) {
        // Implementar usando SDK PAX
    }
    override fun cutPaper() {
        // Implementar usando SDK PAX
    }
    override fun feedPaper(lines: Int) {
        // Implementar usando SDK PAX
    }
}

class DummyPrinter : BasePrinter {
    override fun isAvailable() = false
    override fun getStatus() = mapOf("status" to "not_available")
    override fun printText(text: String, bold: Boolean, doubleWidth: Boolean, doubleHeight: Boolean, center: Boolean) {
        throw Exception("Impressora não disponível")
    }
    override fun printQrCode(data: String) {
        throw Exception("Impressora não disponível")
    }
    override fun cutPaper() {
        throw Exception("Impressora não disponível")
    }
    override fun feedPaper(lines: Int) {
        throw Exception("Impressora não disponível")
    }
}

// Implementações de NFC
class GertecNfcReader(private val context: Context) : BaseNfcReader {
    override fun isAvailable() = true
    override fun readCard(): String? {
        // Implementar usando SDK Gertec
        return null
    }
}

class ElginNfcReader(private val context: Context) : BaseNfcReader {
    override fun isAvailable() = true
    override fun readCard(): String? {
        // Implementar usando SDK Elgin
        return null
    }
}

class PaxNfcReader(private val context: Context) : BaseNfcReader {
    override fun isAvailable() = true
    override fun readCard(): String? {
        // Implementar usando SDK PAX
        return null
    }
}

class DummyNfcReader : BaseNfcReader {
    override fun isAvailable() = false
    override fun readCard(): String? {
        throw Exception("NFC não disponível")
    }
}
