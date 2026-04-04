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

  // -- Outbound
  TTexts.outboundTransactionTitle: 'Outbound Transaction',
  TTexts.searchDot: 'Search ...',
  TTexts.confirmExport: 'Confirm export',
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

  // --- Mới thêm để khử hardcode ---
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
  TTexts.priceChangeMessage: 'You have modified the prices for some items in this transaction. Do you want to permanently update their default prices in the catalog?',
  TTexts.updatePricesAndCreate: 'Update Prices & Complete',
  TTexts.justCreateTransaction: 'No, Just Complete Transaction',
  TTexts.transactionSuccessTitle: 'Transaction success!!!',
  TTexts.transactionSuccessSub: 'Your transaction is complete.\nPlease check your stock!',
  TTexts.transactionNumber: 'Transaction Number',
  TTexts.transactionDate: 'Transaction Date',
  TTexts.transactionType: 'Transaction Type',
  TTexts.totalItemsTransaction: 'Total Items / Transaction',
  TTexts.checkDetails: 'Check Details',
  TTexts.transactionDetails: 'Transaction Details',
  TTexts.reasonSales: 'Sales',
  TTexts.reasonDamaged: 'Damaged / Expired',
  TTexts.reasonReturn: 'Returned to Supplier',
  TTexts.reasonOther: 'Other',
};
