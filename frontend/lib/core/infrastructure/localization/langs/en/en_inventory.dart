import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enInventory = {
  TTexts.inventoryHub: 'Inventory Hub',
  TTexts.manageProductsStock: 'Manage products & stock levels',
  // -- Inventory Module
  TTexts.details: 'Details',
  TTexts.inboundOutbound7Days: 'Inbound vs Outbound (7 Days)',
  TTexts.inventoryTitle: 'Inventory',
  TTexts.inventoryInsights: 'Inventory Insights',
  TTexts.manageData: 'Manage Data',
  TTexts.productCatalog: 'Product Catalog',

  // -- Inventory Header & Health
  TTexts.totalItems: 'Total Items',
  TTexts.stockValue: 'Stock Value',
  TTexts.stockHealth: 'Stock Health',
  TTexts.statusHealthy: 'Healthy',
  TTexts.statusLow: 'Low',
  TTexts.statusOut: 'Out',

  // -- Inventory Distribution & Flow
  TTexts.topCategoriesByVolume: 'Top Categories by Volume',
  TTexts.stockFlow: 'Stock Flow',
  TTexts.flowIn: 'In',
  TTexts.flowOut: 'Out',

  // -- Inventory Categories
  TTexts.items: 'items',
  TTexts.more: 'More',

  // -- Inventory Insight
  TTexts.insightsOverview: 'Insights Overview',
  TTexts.actionRequired: 'Action Required',
  TTexts.goodCondition: 'Good Condition',
  TTexts.inventoryList: 'Inventory',
  TTexts.tabAll: 'All',
  TTexts.allItems: 'All Items',
  TTexts.tabHealthy: 'Healthy',
  TTexts.tabLowStock: 'Low Stock',
  TTexts.tabOutStock: 'Out of Stock',
  TTexts.sku: 'SKU',
  TTexts.inStock: 'In Stock',
  TTexts.totalInventory: 'Total Inventory',
  TTexts.clearFilters: 'Clear Filters',
  TTexts.emptyFilterMessage:
      "Try adjusting the filters or categories to find what you're looking for.",

  // -- Inventory Detail
  TTexts.inventoryDetails: 'Inventory Details',
  TTexts.quantityInStock: 'Quantity in Stock',
  TTexts.reorderThreshold: 'Reorder Threshold',
  TTexts.importPrice: 'Import Price',
  TTexts.adjustStock: 'Adjust Stock',
  TTexts.totalInStock: 'Total in Stock',
  TTexts.lowStockAlert: 'Low Stock Alert',
  TTexts.noThreshold: 'No threshold',
  TTexts.productSku: 'Product SKU',
  TTexts.productPrice: 'Product Price',
  TTexts.totalValue: 'Total Value',
  TTexts.editItem: 'Edit Item',
  TTexts.deleteItem: 'Delete Item',
  TTexts.addToTransaction: 'Add to Transaction',
  TTexts.deleteConfirmation: 'Delete Confirmation',
  TTexts.confirmDeleteText: 'Are you sure you want to delete this item?',
  TTexts.delete: 'Delete',
  TTexts.barcodeType: 'Type',
  TTexts.noLimit: 'No limit',
  TTexts.thresholdTitle: 'Threshold',
  TTexts.totalStockTitle: 'Total Stock',
  TTexts.featureComingSoon: 'This feature is coming soon!',
  TTexts.itemDeletedSuccess: 'Deleted',
  TTexts.itemDeletedMessage: 'Item has been deleted successfully!',
  TTexts.info: 'Info',
  TTexts.totalStockInTitle: 'Total Stock In',
  TTexts.totalStockOutTitle: 'Total Stock Out',
  TTexts.importCost: 'Import Cost',
  TTexts.salePrice: 'Sale Price',
  TTexts.profitMargin: 'Profit Margin',
  TTexts.barcodeLabel: 'Barcode',
  TTexts.noRelatedPackages: 'No other packages available for this product.',
  TTexts.unknownPackage: 'Unknown Package',
  TTexts.left: 'left',
  TTexts.stockMovement: 'Stock Movement',
  TTexts.data: 'Data',
  TTexts.chart: 'Chart',
  TTexts.stockIn: 'Stock In',
  TTexts.stockOut: 'Stock Out',
  TTexts.inventoryStatus: 'Inventory Status',
  TTexts.relatedPackages: 'Related Packages',
  TTexts.inventoryHistory: 'Inventory History',
  TTexts.latestInventoryCount: 'Latest Inventory Count',
  TTexts.restockFromSupplier: 'Restock from Supplier',
  TTexts.salesOrder: 'Sales Order #1023',
  TTexts.loadingProduct: 'Loading product details...',
  TTexts.viewProductInfo: 'View Product Info',
  TTexts.productDataMissing: 'Product data is missing',

  // -- Product Catalog & Categories ---
  TTexts.categoryCatalog: 'Product Catalog',
  TTexts.searchCategories: 'Search categories...',
  TTexts.totalCategories: 'Total',
  TTexts.categoriesUnit: 'categories',
  TTexts.addNewCategory: 'Add New Category',
  TTexts.addNewCategorySub:
      'Create a new classification group for your inventory items.',
  TTexts.categoryDescription: 'Category Description',
  TTexts.noCategoryDescription: 'This category does not have description',
  TTexts.emptyCategoryMessage:
      'We couldn\'t find any categories matching your search. Try a different keyword or add a new category.',

  // -- Category Detail
  TTexts.addNewProduct: 'Add New Product',
  TTexts.addNewProductSub: 'Add a new product item to this category.',
  TTexts.editCategory: 'Edit Category',
  TTexts.deleteCategory: 'Delete Category',
  TTexts.noProductsFound: 'No Products Found',
  TTexts.noProductsAssigned:
      'There are currently no products assigned to this category.',
  TTexts.deleteCategoryConfirm:
      'Are you sure you want to delete this category?',
  TTexts.deleting: 'Deleting...',

  // -- Product Catalog Detail
  TTexts.brand: 'Brand',
  TTexts.packagesOrVariants: 'Packages / Variants',
  TTexts.add: 'Add',
  TTexts.noPackagesFound: 'No Packages Found',
  TTexts.addPackageSubtitle:
      'Add a package (variant, unit, barcode) for this product to manage stock.',
  TTexts.noBarcode: 'No Barcode',
  TTexts.editProduct: 'Edit Product',
  TTexts.deleteProduct: 'Delete Product',
  TTexts.addNewPackage: 'Add New Package',
  TTexts.editPackage: 'Edit Package',

  // -- Add Category
  TTexts.categoryNameLabel: 'Category Name',
  TTexts.categoryNameHint: 'e.g. Beauty & Personal Care',
  TTexts.categoryDescLabel: 'Description (Optional)',
  TTexts.categoryDescHint: 'Brief details about this category...',
  TTexts.saveCategory: 'Save Category',
  TTexts.categoryNameRequired: 'Category name is required.',
  TTexts.categoryCreatedSuccessTitle: 'Success',
  TTexts.categoryCreatedSuccessMessage:
      'Category has been created successfully.',
  TTexts.categoryNameExists: 'This category name already exists in your store.',
  TTexts.saving: 'Saving...',
  TTexts.savingCategory: 'Saving category...',

  // -- Edit Category
  TTexts.editCategoryTitle: 'Edit Category',
  TTexts.categoryUpdatedSuccessMessage:
      'Category has been updated successfully.',
  TTexts.deleteCategorySuccessMessage: 'Category has been deleted.',
  TTexts.categoryNotEmptyError:
      'Cannot delete. Please remove or clear inventory of all products inside this category first.',

  // -- Add Product
  TTexts.addNewProductTitle: 'Add New Product',
  TTexts.editProductTitle: 'Edit Product Info',
  TTexts.productNameLabel: 'Product Name',
  TTexts.productNameSubLabel: 'e.g. Product name...',
  TTexts.selectCategory: 'Select Category',
  TTexts.initialPackageInfo: 'Initial Package (Required)',
  TTexts.unitLabel: 'Unit (Piece, Box...)',
  TTexts.productCreatedSuccess:
      'Product and initial package created successfully.',
  TTexts.productUpdatedSuccess: 'Product updated successfully.',
  TTexts.step1: 'Step 1',
  TTexts.step2: 'Step 2',
  TTexts.baseInfo: 'Base Info',
  TTexts.packageInfo: 'Package Info',
  TTexts.nextStep: 'Next Step',
  TTexts.previousStep: 'Back',
  TTexts.variantNameLabel: 'Variant Name',
  TTexts.variantNameHint: 'e.g. 150ml Tube, Red Color',
  TTexts.selectCategoryWarning: 'Please select a category first.',
  TTexts.brandSub: 'e.g. Brand',
  TTexts.tapToSelect: 'Tap to select...',
  TTexts.step1Title: 'Base Information',
  TTexts.step1Sub: 'Provide the basic details of your new product.',
  TTexts.step2Title: 'Initial Package',
  TTexts.step2Sub:
      'Create the first unit variant and pricing for this product.',
  TTexts.productImage: 'Product Image',
  TTexts.uploadImage: 'Upload Image',
  TTexts.takePhoto: 'Take Photo',
  TTexts.chooseFromGallery: 'Choose from Gallery',
  TTexts.stepProductBaseInfo: 'Base Info',
  TTexts.stepProductImage: 'Photo',
  TTexts.stepProductPackage: 'Pricing',
  TTexts.productBaseTitle: 'Base Information',
  TTexts.productBaseSub: 'Let\'s start with product name, brand, and category.',
  TTexts.productImageTitle: 'Product Photo',
  TTexts.productImageSub: 'Take or upload a photo of this product.',
  TTexts.productPackageTitle: 'Initial Package & Pricing',
  TTexts.productPackageSub:
      'Define the first variant (e.g. 1 Box) and its prices.',
  TTexts.requirePhoto: 'Please take or choose a product photo first.',
  TTexts.cameraPermissionDenied:
      'Camera permission is required to take photos. Please enable it in settings.',
  TTexts.scanOrTypeBarcode: 'Scan or type...',
  TTexts.zeroPointZero: "0.00",
  TTexts.selectUnit: 'Select unit...',
  TTexts.discardChangesTitle: 'Discard Changes?',
  TTexts.discardChangesMessage:
      'Are you sure you want to go back? All your entered data will be lost.',
  TTexts.discard: 'Discard',
  TTexts.keepEditing: 'Keep Editing',
  TTexts.confirmNoImageTitle: 'No Photo Selected',
  TTexts.confirmNoImageMessage:
      'Are you sure you want to proceed without a product photo?',
  TTexts.yesContinue: 'Yes, Proceed',
  TTexts.addPhoto: 'Add Photo',
  TTexts.cropImage: 'Edit Photo',
  TTexts.reorderThresholdLabel: 'Low Stock Alert At',
  TTexts.reorderThresholdHint: 'e.g. 5',

  // -- Edit Product
  TTexts.editProductImageTitle: 'Edit Product Image',
  TTexts.editProductImageSub: 'Update the main photo for this product.',
  TTexts.editPackageTitle: 'Edit Package',
  TTexts.editPackageSub:
      'Update pricing, barcode, and threshold for this package.',
  TTexts.addPackageTitle: 'Add New Package',
  TTexts.addPackageSub: 'Create a new variant or unit for this product.',
  TTexts.saveChanges: 'Save Changes',
  TTexts.saveImage: 'Save Image',
  TTexts.savePackage: 'Save Package',
  TTexts.deletePackage: 'Delete Package',
  TTexts.addPackageBtn: 'Add Package',
  TTexts.imageUpdatedSuccess: 'Product image updated successfully.',
  TTexts.packageUpdatedSuccess: 'Package updated successfully.',
  TTexts.packageCreatedSuccess: 'New package created successfully.',
  TTexts.deletingProduct: 'Deleting product...',
  TTexts.productDeletedSuccess: 'Product has been moved to trash.',
  TTexts.deletingPackage: 'Deleting package...',
  TTexts.packageDeletedSuccess: 'Package has been moved to trash.',
  TTexts.productNotEmptyError:
      'Cannot delete product. Please delete or empty all packages first.',
  TTexts.confirmMoveProductToTrash:
      'Are you sure you want to move this product to trash?',
  TTexts.confirmMovePackageToTrash:
      'Are you sure you want to move this package to trash?',
  TTexts.inventoryNotEmptyTitle: 'Inventory Not Empty',
  TTexts.inventoryNotEmptyMessage:
      'You cannot delete this package because there is still stock in the inventory. Please check out the remaining items first.',
  TTexts.makeTransaction: 'Make Transaction',
  TTexts.confirmDeletePackageMessage:
      'Are you sure you want to delete this package? This will mark it as inactive in your system.',
  TTexts.currentStockWithCount: 'Current stock: @count',
  TTexts.importPriceLabel: 'Import Price',
  TTexts.sellingPriceLabel: 'Selling Price',
  TTexts.stockQuantityLabel: 'Stock',
  TTexts.inventoryThreshold: 'Threshold',
  TTexts.sellingPrice: 'Sale Price',

  // -- Empty States
  TTexts.noDataAvailable: 'No data available',
  TTexts.noCategoriesFound: 'No categories found',
};
