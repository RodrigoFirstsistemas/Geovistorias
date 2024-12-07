package br.com.sistema_vistorias

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import stone.application.StoneStart
import stone.application.interfaces.StoneCallbackInterface
import stone.providers.TransactionProvider
import stone.utils.Stone
import stone.database.transaction.TransactionObject
import stone.database.transaction.TransactionDAO

class StonePaymentPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var currentTransaction: TransactionObject? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "br.com.sistema_vistorias/stone_sdk")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val terminalModel = call.argument<String>("terminalModel") ?: "unknown"
        
        when (call.method) {
            "initializeSdk" -> initializeSdk(terminalModel, result)
            "activateCode" -> activateCode(call, terminalModel, result)
            "makePayment" -> makePayment(call, terminalModel, result)
            "cancelPayment" -> cancelPayment(call, terminalModel, result)
            "getTransactionStatus" -> getTransactionStatus(call, terminalModel, result)
            "printReceipt" -> printReceipt(call, terminalModel, result)
            "checkPinpadConnection" -> checkPinpadConnection(terminalModel, result)
            else -> result.notImplemented()
        }
    }

    private fun initializeSdk(terminalModel: String, result: MethodChannel.Result) {
        try {
            // Configurar SDK de acordo com o terminal
            when (terminalModel) {
                "gpos720", "gpos780" -> {
                    Stone.setAppName("Sistema Vistorias - Gertec")
                    // Configurações específicas Gertec
                }
                "l300", "l400" -> {
                    Stone.setAppName("Sistema Vistorias - Elgin")
                    // Configurações específicas Elgin
                }
                "p2", "p2Mini", "a8Gpos700x" -> {
                    Stone.setAppName("Sistema Vistorias - PAX")
                    // Configurações específicas PAX
                }
                else -> {
                    Stone.setAppName("Sistema Vistorias")
                }
            }

            StoneStart.init(context)
            result.success(true)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun activateCode(call: MethodCall, terminalModel: String, result: MethodChannel.Result) {
        val stoneCode = call.argument<String>("stoneCode") ?: run {
            result.error("INVALID_ARGUMENT", "Stone Code é obrigatório", null)
            return
        }

        try {
            Stone.addStoneCode(stoneCode)
            result.success(true)
        } catch (e: Exception) {
            result.error("ACTIVATION_ERROR", e.message, null)
        }
    }

    private fun makePayment(call: MethodCall, terminalModel: String, result: MethodChannel.Result) {
        val amount = call.argument<Int>("amount") ?: run {
            result.error("INVALID_ARGUMENT", "Valor é obrigatório", null)
            return
        }
        val orderId = call.argument<String>("orderId") ?: run {
            result.error("INVALID_ARGUMENT", "Order ID é obrigatório", null)
            return
        }
        val installments = call.argument<String>("installments") ?: "1"
        val paymentType = call.argument<String>("paymentType") ?: "credit"
        val customerName = call.argument<String>("customerName")
        val customerDocument = call.argument<String>("customerDocument")

        try {
            val transaction = TransactionObject()
            transaction.amount = amount
            transaction.orderId = orderId
            transaction.installments = installments.toInt()
            transaction.typeOfTransaction = when(paymentType.toLowerCase()) {
                "credit" -> Stone.CREDIT
                "debit" -> Stone.DEBIT
                "pix" -> Stone.PIX
                else -> Stone.CREDIT
            }
            
            if (!customerName.isNullOrEmpty()) {
                transaction.customerName = customerName
            }
            if (!customerDocument.isNullOrEmpty()) {
                transaction.customerDocument = customerDocument
            }

            // Configurações específicas por terminal
            when (terminalModel) {
                "gpos720", "gpos780" -> {
                    // Configurações Gertec
                    transaction.dialogMessage = "Insira ou aproxime o cartão"
                    transaction.dialogTitle = "Sistema Vistorias"
                }
                "l300", "l400" -> {
                    // Configurações Elgin
                    transaction.dialogMessage = "Aguardando cartão"
                    transaction.dialogTitle = "Sistema Vistorias"
                }
                "p2", "p2Mini", "a8Gpos700x" -> {
                    // Configurações PAX
                    transaction.dialogMessage = "Insira, aproxime ou passe o cartão"
                    transaction.dialogTitle = "Sistema Vistorias"
                }
            }

            currentTransaction = transaction

            val provider = TransactionProvider(context, transaction)
            provider.useDefaultUI(true)
            provider.connectionCallback = object : StoneCallbackInterface {
                override fun onSuccess() {
                    val response = mapOf(
                        "transactionId" to transaction.idFromAuthorizer,
                        "amount" to transaction.amount,
                        "status" to "approved",
                        "type" to paymentType,
                        "installments" to installments,
                        "cardBrand" to transaction.cardBrand,
                        "authorizationCode" to transaction.authorizationCode,
                        "nsu" to transaction.nsu
                    )
                    result.success(response)
                }

                override fun onError() {
                    result.error("TRANSACTION_ERROR", transaction.errorCode, null)
                }
            }
            provider.execute()
        } catch (e: Exception) {
            result.error("PAYMENT_ERROR", e.message, null)
        }
    }

    private fun cancelPayment(call: MethodCall, terminalModel: String, result: MethodChannel.Result) {
        val transactionId = call.argument<String>("transactionId") ?: run {
            result.error("INVALID_ARGUMENT", "Transaction ID é obrigatório", null)
            return
        }
        val amount = call.argument<Int>("amount") ?: run {
            result.error("INVALID_ARGUMENT", "Valor é obrigatório", null)
            return
        }
        val reason = call.argument<String>("reason")

        try {
            val transaction = TransactionObject()
            transaction.amount = amount
            transaction.idFromAuthorizer = transactionId
            if (!reason.isNullOrEmpty()) {
                transaction.cancellationReason = reason
            }

            // Configurações específicas por terminal
            when (terminalModel) {
                "gpos720", "gpos780" -> {
                    // Configurações Gertec
                    transaction.dialogMessage = "Processando cancelamento"
                    transaction.dialogTitle = "Sistema Vistorias"
                }
                "l300", "l400" -> {
                    // Configurações Elgin
                    transaction.dialogMessage = "Cancelando transação"
                    transaction.dialogTitle = "Sistema Vistorias"
                }
                "p2", "p2Mini", "a8Gpos700x" -> {
                    // Configurações PAX
                    transaction.dialogMessage = "Aguarde o cancelamento"
                    transaction.dialogTitle = "Sistema Vistorias"
                }
            }

            val provider = TransactionProvider(context, transaction)
            provider.useDefaultUI(true)
            provider.connectionCallback = object : StoneCallbackInterface {
                override fun onSuccess() {
                    val response = mapOf(
                        "transactionId" to transaction.idFromAuthorizer,
                        "amount" to transaction.amount,
                        "status" to "cancelled"
                    )
                    result.success(response)
                }

                override fun onError() {
                    result.error("CANCELLATION_ERROR", transaction.errorCode, null)
                }
            }
            provider.execute()
        } catch (e: Exception) {
            result.error("CANCELLATION_ERROR", e.message, null)
        }
    }

    private fun getTransactionStatus(call: MethodCall, terminalModel: String, result: MethodChannel.Result) {
        val transactionId = call.argument<String>("transactionId") ?: run {
            result.error("INVALID_ARGUMENT", "Transaction ID é obrigatório", null)
            return
        }

        try {
            val transaction = TransactionDAO.findTransactionWithId(transactionId)
            if (transaction != null) {
                val response = mapOf(
                    "transactionId" to transaction.idFromAuthorizer,
                    "amount" to transaction.amount,
                    "status" to when {
                        transaction.isApproved -> "approved"
                        transaction.isDenied -> "denied"
                        transaction.isCancelled -> "cancelled"
                        else -> "processing"
                    }
                )
                result.success(response)
            } else {
                result.error("NOT_FOUND", "Transação não encontrada", null)
            }
        } catch (e: Exception) {
            result.error("STATUS_ERROR", e.message, null)
        }
    }

    private fun printReceipt(call: MethodCall, terminalModel: String, result: MethodChannel.Result) {
        val transactionId = call.argument<String>("transactionId") ?: run {
            result.error("INVALID_ARGUMENT", "Transaction ID é obrigatório", null)
            return
        }
        val isCustomerCopy = call.argument<Boolean>("isCustomerCopy") ?: false

        try {
            val transaction = TransactionDAO.findTransactionWithId(transactionId)
            if (transaction != null) {
                val provider = TransactionProvider(context, transaction)
                provider.useDefaultUI(true)
                provider.connectionCallback = object : StoneCallbackInterface {
                    override fun onSuccess() {
                        result.success(true)
                    }

                    override fun onError() {
                        result.error("PRINT_ERROR", transaction.errorCode, null)
                    }
                }

                // Configurações específicas por terminal
                when (terminalModel) {
                    "gpos720", "gpos780" -> {
                        // Impressão Gertec
                        if (isCustomerCopy) {
                            provider.printCustomerReceiptInGertecPrinter()
                        } else {
                            provider.printMerchantReceiptInGertecPrinter()
                        }
                    }
                    "l300", "l400" -> {
                        // Impressão Elgin
                        if (isCustomerCopy) {
                            provider.printCustomerReceiptInElginPrinter()
                        } else {
                            provider.printMerchantReceiptInElginPrinter()
                        }
                    }
                    "p2", "p2Mini", "a8Gpos700x" -> {
                        // Impressão PAX
                        if (isCustomerCopy) {
                            provider.printCustomerReceiptInPaxPrinter()
                        } else {
                            provider.printMerchantReceiptInPaxPrinter()
                        }
                    }
                    else -> {
                        if (isCustomerCopy) {
                            provider.printCustomerReceipt()
                        } else {
                            provider.printMerchantReceipt()
                        }
                    }
                }
            } else {
                result.error("NOT_FOUND", "Transação não encontrada", null)
            }
        } catch (e: Exception) {
            result.error("PRINT_ERROR", e.message, null)
        }
    }

    private fun checkPinpadConnection(terminalModel: String, result: MethodChannel.Result) {
        try {
            val pinpads = Stone.getPinpads()
            if (pinpads.isNotEmpty()) {
                // Verificar conexão específica por terminal
                when (terminalModel) {
                    "gpos720", "gpos780" -> {
                        // Verificação Gertec
                        result.success(checkGertecPinpadConnection())
                    }
                    "l300", "l400" -> {
                        // Verificação Elgin
                        result.success(checkElginPinpadConnection())
                    }
                    "p2", "p2Mini", "a8Gpos700x" -> {
                        // Verificação PAX
                        result.success(checkPaxPinpadConnection())
                    }
                    else -> {
                        result.success(pinpads[0].isConnected)
                    }
                }
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("CONNECTION_ERROR", e.message, null)
        }
    }

    private fun checkGertecPinpadConnection(): Boolean {
        // Implementar verificação específica Gertec
        return true
    }

    private fun checkElginPinpadConnection(): Boolean {
        // Implementar verificação específica Elgin
        return true
    }

    private fun checkPaxPinpadConnection(): Boolean {
        // Implementar verificação específica PAX
        return true
    }
}
