import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enTransaction = {
  TTexts.createNewTransaction: "Create New Transaction",
  TTexts.manageInventory: "Manage Inventory",
  TTexts.manageInventoryDesc:
      "Record incoming items, outbound shipments, or adjust your current stock.",
  TTexts.inbound: "Inbound",
  TTexts.outbound: "Outbound",
  TTexts.stockAdjustment: "Stock Adjustment",
  TTexts.exit: "Exit",

  // -- Inbound
  TTexts.inboundTransaction: "Inbound Transaction",
  TTexts.emptyInboundCartTitle: "No items yet",
  TTexts.emptyInboundCartSub:
      "Scan a barcode or tap the search bar to add products to this transaction.",
  TTexts.completeImport: "Complete Import",
  TTexts.totalFunds: "Total funds",
  TTexts.searchProductToAdd: "Search product to add...",
  TTexts.emptyTransactionTitle: "No items yet",
  TTexts.emptyTransactionSubtitle:
      "Scan a barcode or tap the search bar to add products to this transaction.",
  TTexts.transactionCompletedTitle: "Transaction Completed!",
  TTexts.transactionCompletedSubtitle:
      "Your transaction has been processed and saved successfully.",
  TTexts.backToHome: "Back to Home",
  TTexts.scanProductBarcode: "Scan Product Barcode",
  TTexts.confirmImportTitle: "Confirm Import",
  TTexts.confirmImportDescription: "Are you sure you want to complete this inbound transaction? This action will add stock to your inventory.",
  TTexts.proceedImport: "Confirm & Import",

  // -- Outbound
  TTexts.outboundTransactionTitle: 'Outbound Transaction',
  TTexts.searchDot: 'Search ...',
  TTexts.completeExport: 'Complete Export',
  TTexts.stocksLabel: 'Stocks:',
  TTexts.outOfStockAlert: 'Not enough stock available!',

  // --- Transaction Item Add ---
  TTexts.loadingAddingToCart: "Adding to transaction...",
  TTexts.productNameUnknown: "Unknown Product",
  TTexts.labelNoBarcode: "N/A",
  TTexts.labelStock: "Stock",
  TTexts.labelImportPrice: "Import Price (\$)",
  TTexts.labelQuantity: "Quantity",
  TTexts.labelTicket: "Ticket",
  TTexts.errorNoPackageId: "Package ID not found or invalid",
  TTexts.item: "Item",
  TTexts.subtotal: "Subtotal",
  TTexts.removeItem: "Remove Item",
  TTexts.confirmRemoveItemTransaction:
      "Are you sure you want to remove this item from the transaction?",
  TTexts.remove: "Remove",
  TTexts.creatingImportTicket: "Creating import ticket...",
  TTexts.manualImport: "Manual Import",
  TTexts.importTicketCreated: "Import ticket has been created successfully!",
  TTexts.errorCreatingImportTicket: "Failed to create import ticket.",
  TTexts.uncategorized: "Uncategorized",
  TTexts.noBrand: "No Brand",
  TTexts.inactive: "Inactive",
  TTexts.product: "Product",
  TTexts.recentlyAddedSuggested: "Recently Added / Suggested",
  TTexts.checkoutDetails: 'Checkout Details',
  TTexts.transactionReason: 'Reason',
  TTexts.selectReason: 'Select a reason',
  TTexts.transactionNote: 'Note (Optional)',
  TTexts.noteHint: 'Enter any additional details...',
  TTexts.priceChangeDetected: 'Price Change Detected',
  TTexts.priceChangeMessage:
      'You have modified the prices for some items in this transaction. Do you want to permanently update their default prices in the catalog?',
  TTexts.updatePricesAndCreate: 'Update Prices & Complete',
  TTexts.justCreateTransaction: 'No, Just Complete Transaction',
  TTexts.transactionSuccessTitle: 'Transaction success!!!',
  TTexts.transactionSuccessSub:
      'Your transaction is complete.\nPlease check your stock!',
  TTexts.transactionNumber: 'Transaction Number',
  TTexts.transactionDate: 'Transaction Date',
  TTexts.transactionType: 'Transaction Type',
  TTexts.totalItemsTransaction: 'Total Items / Transaction',
  TTexts.checkDetails: 'Check Details',
  TTexts.transactionDetails: 'Transaction Details',
  TTexts.selectExportType: "Select Export Types:",

  // Specific Reasons
  TTexts.reasonRetailSale: 'Retail Sale',
  TTexts.reasonWholesale: 'Wholesale',
  TTexts.reasonDamaged: 'Damaged / Expired',
  TTexts.reasonInternalTransfer: 'Internal Transfer',
  TTexts.reasonReturn: 'Returned to Supplier',
  TTexts.reasonOther: 'Other',
  TTexts.reasonIncome: 'Income (+)',
  TTexts.reasonNeutral: 'No Revenue (0)',
  TTexts.reasonExpense: 'Expense / Loss (-)',

  TTexts.selectBatchFIFO: 'Select batches',
  TTexts.batchRemaining: 'left',
  TTexts.expiresOn: 'Exp',
  TTexts.batchExceedsStock: 'Quantity exceeds the selected batch stock!',
  TTexts.quantityToExport: 'Quantity to export',
  TTexts.importPriceLot: 'Import Price',
  TTexts.sellingPriceLot: 'Selling Price',
  TTexts.quantityToImport: 'Quantity to import',
  TTexts.importedOn: "Imported",
  TTexts.outOfStockBatch: "Out of stock",
  TTexts.confirmExportTitle: "Confirm Export",
  TTexts.confirmExportDescription:
      "Are you sure you want to complete this outbound transaction? This action will update your inventory levels.",
  TTexts.processingExport: "Processing Export...",
  TTexts.exportSuccessMessage: "Export transaction completed successfully!",
  TTexts.noteLabel: "Note",
  TTexts.emptyCartWarning:
      "Your cart is empty. Please add products before exporting.",
  TTexts.priceChangeDetectedTitle: "Price Change Detected",
  TTexts.priceChangeDetectedDesc:
      "The following items have modified selling prices:",
  TTexts.proceedExport: "Confirm & Export",
  TTexts.reasonForExport: "Reason for Export",
  TTexts.total: "Total",
  TTexts.totalQuantity: "Total Quantity",
  TTexts.specifyBatchQuantity:
      "Please specify the quantity from the batches above.",
};
