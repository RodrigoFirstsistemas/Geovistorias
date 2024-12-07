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

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "br.com.sistema_vistorias/stone_sdk")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initializeSdk" -> initializeSdk(result)
            "activateCode" -> activateCode(call, result)
            "makePayment" -> makePayment(call, result)
            "cancelPayment" -> cancelPayment(call, result)
            "getTransactionStatus" -> getTransactionStatus(call, result)
            "printReceipt" -> printReceipt(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initializeSdk(result: MethodChannel.Result) {
        try {
            Stone.setAppName("Sistema Vistorias")
            StoneStart.init(context)
            result.success(true)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun activateCode(call: MethodCall, result: MethodChannel.Result) {
        val stoneCode = call.argument<String>("stoneCode")
            ?: return result.error("INVALID_ARGUMENTS", "Stone Code é obrigatório", null)

        try {
            Stone.setAppName("Sistema Vistorias")
            StoneStart.init(context)

            val callback = object : StoneCallbackInterface {
                override fun onSuccess() {
                    result.success(true)
                }

                override fun onError() {
                    result.error("ACTIVATION_ERROR", "Erro ao ativar código Stone", null)
                }
            }

            Stone.activateCode(stoneCode, callback)
        } catch (e: Exception) {
            result.error("ACTIVATION_ERROR", e.message, null)
        }
    }

    private fun makePayment(call: MethodCall, result: MethodChannel.Result) {
        val amount = call.argument<Int>("amount")
            ?: return result.error("INVALID_ARGUMENTS", "Valor é obrigatório", null)
        val orderId = call.argument<String>("orderId")
            ?: return result.error("INVALID_ARGUMENTS", "ID do pedido é obrigatório", null)
        val installments = call.argument<String>("installments")
            ?: return result.error("INVALID_ARGUMENTS", "Número de parcelas é obrigatório", null)
        val paymentType = call.argument<String>("paymentType")
            ?: return result.error("INVALID_ARGUMENTS", "Tipo de pagamento é obrigatório", null)

        try {
            val transaction = TransactionObject()
            transaction.amount = amount
            transaction.installments = installments.toInt()
            transaction.orderId = orderId
            transaction.typeOfTransaction = if (paymentType == "credit") TransactionObject.CREDIT else TransactionObject.DEBIT

            val provider = TransactionProvider(transaction)
            provider.connectionCallback = object : StoneCallbackInterface {
                override fun onSuccess() {
                    val transactionResult = mapOf(
                        "transactionId" to transaction.idFromAuthorize,
                        "amount" to transaction.amount,
                        "installments" to transaction.installments,
                        "type" to transaction.typeOfTransaction,
                        "status" to transaction.transactionStatus,
                        "date" to transaction.date.time,
                        "cardBrand" to transaction.cardBrand,
                        "authorizationCode" to transaction.authorizationCode,
                        "orderId" to transaction.orderId
                    )
                    result.success(transactionResult)
                }

                override fun onError() {
                    result.error("TRANSACTION_ERROR", "Erro ao processar pagamento", null)
                }
            }

            provider.execute()
        } catch (e: Exception) {
            result.error("TRANSACTION_ERROR", e.message, null)
        }
    }

    private fun cancelPayment(call: MethodCall, result: MethodChannel.Result) {
        val transactionId = call.argument<String>("transactionId")
            ?: return result.error("INVALID_ARGUMENTS", "ID da transação é obrigatório", null)
        val amount = call.argument<Int>("amount")
            ?: return result.error("INVALID_ARGUMENTS", "Valor é obrigatório", null)

        try {
            val transaction = TransactionDAO.findTransactionWithId(transactionId)
                ?: return result.error("TRANSACTION_NOT_FOUND", "Transação não encontrada", null)

            transaction.amount = amount
            
            val provider = TransactionProvider(transaction)
            provider.connectionCallback = object : StoneCallbackInterface {
                override fun onSuccess() {
                    val cancellationResult = mapOf(
                        "transactionId" to transaction.idFromAuthorize,
                        "amount" to transaction.amount,
                        "status" to transaction.transactionStatus,
                        "date" to transaction.date.time
                    )
                    result.success(cancellationResult)
                }

                override fun onError() {
                    result.error("CANCELLATION_ERROR", "Erro ao cancelar pagamento", null)
                }
            }

            provider.executeCancel()
        } catch (e: Exception) {
            result.error("CANCELLATION_ERROR", e.message, null)
        }
    }

    private fun getTransactionStatus(call: MethodCall, result: MethodChannel.Result) {
        val transactionId = call.argument<String>("transactionId")
            ?: return result.error("INVALID_ARGUMENTS", "ID da transação é obrigatório", null)

        try {
            val transaction = TransactionDAO.findTransactionWithId(transactionId)
                ?: return result.error("TRANSACTION_NOT_FOUND", "Transação não encontrada", null)

            val statusResult = mapOf(
                "transactionId" to transaction.idFromAuthorize,
                "status" to transaction.transactionStatus,
                "date" to transaction.date.time,
                "amount" to transaction.amount
            )
            result.success(statusResult)
        } catch (e: Exception) {
            result.error("STATUS_ERROR", e.message, null)
        }
    }

    private fun printReceipt(call: MethodCall, result: MethodChannel.Result) {
        val transactionId = call.argument<String>("transactionId")
            ?: return result.error("INVALID_ARGUMENTS", "ID da transação é obrigatório", null)

        try {
            val transaction = TransactionDAO.findTransactionWithId(transactionId)
                ?: return result.error("TRANSACTION_NOT_FOUND", "Transação não encontrada", null)

            val provider = TransactionProvider(transaction)
            provider.connectionCallback = object : StoneCallbackInterface {
                override fun onSuccess() {
                    result.success(true)
                }

                override fun onError() {
                    result.error("PRINT_ERROR", "Erro ao imprimir comprovante", null)
                }
            }

            provider.printReceiptInPOSPrinter()
        } catch (e: Exception) {
            result.error("PRINT_ERROR", e.message, null)
        }
    }
}
