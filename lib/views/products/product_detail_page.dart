import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_detail_viewmodel.dart';
import '../../models/products/product_detail_model.dart';
import '../auth/login_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int productID;

  const ProductDetailPage({super.key, required this.productID});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Klasik E-Ticaret Fiyat Rengi
  final Color _priceColor = const Color(0xFFF27A1A);
  final Color _successGreen = const Color(0xFF0BC15C);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetail();
    });
  }

  void _loadProductDetail() {
    final authViewModel = context.read<AuthViewModel>();
    final token = authViewModel.loginResponse?.data?.token;

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    context.read<ProductDetailViewModel>().loadProductDetail(
          token,
          widget.productID,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<ProductDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (viewModel.errorMessage != null && viewModel.productDetail == null) {
            return _buildErrorState(viewModel);
          }

          if (viewModel.productDetail == null) {
            return const Center(child: Text('Ürün bulunamadı'));
          }

          final product = viewModel.productDetail!;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(product),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(product),
                    _buildThickDivider(),
                    _buildVariationsSection(product, viewModel),
                    _buildThickDivider(),
                    _buildDescriptionSection(product),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<ProductDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.productDetail == null) return const SizedBox.shrink();
          return _buildBottomActionBar(viewModel);
        },
      ),
    );
  }

  Widget _buildThickDivider() {
    return Container(
      height: 10,
      color: const Color(0xFFEEEDF0),
      width: double.infinity,
    );
  }

  Widget _buildSliverAppBar(ProductDetailData product) {
    return SliverAppBar(
      expandedHeight: 400.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
          ],
        ),
        child: IconButton(
  icon: ImageIcon(
    AssetImage('assets/Icons/geri.png'),
    size: 20,
    color: AppTheme.textPrimary,
  ),
  onPressed: () => Navigator.of(context).pop(),
),

      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 60, bottom: 20),
          child: Hero(
            tag: 'product_${product.productID}',
            child: product.productMainImage.isNotEmpty
                ? Image.network(
                    product.productMainImage,
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.image, size: 100, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ProductDetailData product) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.categories.isNotEmpty)
            Text(
              product.categories.first.catName.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            product.productTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF333333),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.qr_code, size: 14),
              const SizedBox(width: 8),
              Text(
                product.productCode,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariationsSection(
      ProductDetailData product, ProductDetailViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ürün Seçenekleri',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    if (viewModel.selectedVariantCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${viewModel.selectedVariantCount} Seçili',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.totalVariations} Varyasyon',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.variations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildVariationRow(product.variations[index], viewModel);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVariationRow(
      ProductVariation variation, ProductDetailViewModel viewModel) {
    final sellerData = variation.sellerData;
    final hasDiscount =
        sellerData != null && sellerData.discountPrice < sellerData.price;
    final isSelling = variation.isSelling;
    final selection = viewModel.variantSelections[variation.variantID];
    final isSelected = selection?.isSelected ?? false;
    
    // Düzenlenmiş satışta varyasyonu kontrol et
    final editedVariant = viewModel.editedSellingVariants[variation.variantID];
    final isEdited = editedVariant != null;
    final isMarkedForRemoval = editedVariant?.isRemove ?? false;
    final isUnpublished = editedVariant != null ? !editedVariant.isPublished : (sellerData != null && !sellerData.isPublished);

    return InkWell(
      onTap: isSelling
          ? () => _showSellingVariantEditSheet(variation, viewModel)
          : () => _showVariantEditSheet(variation, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: isMarkedForRemoval
            ? Colors.red.withOpacity(0.05)
            : isEdited
                ? Colors.orange.withOpacity(0.05)
                : isSelected
                    ? AppTheme.primaryColor.withOpacity(0.05)
                    : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox (sadece satışta olmayanlar için)
            if (!isSelling)
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  viewModel.toggleVariantSelection(variation.variantID);
                },
                activeColor: AppTheme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),

            // Sol Taraf: Varyasyon İsmi ve Stok Bilgisi
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variation.variantTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (variation.variantBarcode.isNotEmpty)
                    Text(
                      'Barkod: ${variation.variantBarcode}',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 4),
                  if (isSelling && sellerData != null && sellerData.stock > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Stok: ${sellerData.stock} Adet',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: _successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (isSelling)
                    Text(
                      'Stokta Yok',
                      style:
                          GoogleFonts.poppins(fontSize: 11, color: Colors.red),
                    )
                  else if (isSelected && selection != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Stok: ${selection.stock} • Adet: ${selection.quantity}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Sağ Taraf: Fiyat
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isSelling && sellerData != null) ...[
                    if (hasDiscount)
                      Text(
                        '${sellerData.price.toStringAsFixed(2)} TL',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      hasDiscount
                          ? '${sellerData.discountPrice.toStringAsFixed(2)} TL'
                          : '${sellerData.price.toStringAsFixed(2)} TL',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isMarkedForRemoval ? Colors.grey : _priceColor,
                        decoration: isMarkedForRemoval ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isMarkedForRemoval)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Çıkartılacak',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (isUnpublished)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Yayında Değil',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isEdited ? 'Düzenlendi' : 'Satışta',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isEdited ? Colors.orange : _successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ] else if (isSelected && selection != null) ...[
                    if (selection.discountPrice > 0 &&
                        selection.discountPrice < selection.price)
                      Text(
                        '${selection.price.toStringAsFixed(2)} TL',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      selection.discountPrice > 0
                          ? '${selection.discountPrice.toStringAsFixed(2)} TL'
                          : selection.price > 0
                              ? '${selection.price.toStringAsFixed(2)} TL'
                              : 'Fiyat Girin',
                      style: GoogleFonts.poppins(
                        fontSize: selection.price > 0 ? 18 : 14,
                        fontWeight: FontWeight.w700,
                        color: selection.price > 0
                            ? AppTheme.primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ] else
                    Text(
                      'Satışa Ekle',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // En Sağ: Ok veya Düzenle ikonu
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(
                isSelling ? Icons.check_circle : Icons.edit_outlined,
                color: isSelling ? _successGreen : Colors.grey,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVariantEditSheet(
      ProductVariation variation, ProductDetailViewModel viewModel) {
    final selection = viewModel.variantSelections[variation.variantID];
    if (selection == null) return;

    final priceController = TextEditingController(
        text: selection.price > 0 ? selection.price.toString() : '');
    final discountPriceController = TextEditingController(
        text: selection.discountPrice > 0
            ? selection.discountPrice.toString()
            : '');
    final stockController =
        TextEditingController(text: selection.stock.toString());
    final quantityController =
        TextEditingController(text: selection.quantity.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Varyasyon Bilgileri',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Varyasyon Adı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variation.variantTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (variation.variantBarcode.isNotEmpty)
                            Text(
                              'Barkod: ${variation.variantBarcode}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Fiyat Alanları
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: priceController,
                      label: 'Satış Fiyatı (TL)',
                      icon: Icons.attach_money,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: discountPriceController,
                      label: 'İndirimli Fiyat (TL)',
                      icon: Icons.local_offer_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stok ve Adet Alanları
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: stockController,
                      label: 'Stok Adedi',
                      icon: Icons.warehouse_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: quantityController,
                      label: 'Paket Adedi',
                      icon: Icons.inventory_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final price = double.tryParse(priceController.text) ?? 0;
                    final discountPrice =
                        double.tryParse(discountPriceController.text) ?? 0;
                    final stock = int.tryParse(stockController.text) ?? 0;
                    final quantity =
                        int.tryParse(quantityController.text) ?? 1;

                    viewModel.updateVariantValue(
                      variation.variantID,
                      price: price,
                      discountPrice: discountPrice,
                      stock: stock,
                      quantity: quantity,
                    );

                    // Otomatik seç
                    if (!selection.isSelected && price > 0) {
                      viewModel.toggleVariantSelection(variation.variantID);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Bilgileri Kaydet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Satışta olan varyasyonu düzenleme bottom sheet
  void _showSellingVariantEditSheet(
      ProductVariation variation, ProductDetailViewModel viewModel) {
    final sellerData = variation.sellerData;
    if (sellerData == null) return;

    // Düzenlenmiş varsa ondan al, yoksa mevcut değerlerden
    final editedVariant = viewModel.editedSellingVariants[variation.variantID];
    
    final priceController = TextEditingController(
        text: (editedVariant?.price ?? sellerData.price).toString());
    final discountPriceController = TextEditingController(
        text: (editedVariant?.discountPrice ?? sellerData.discountPrice).toString());
    final stockController = TextEditingController(
        text: (editedVariant?.stock ?? sellerData.stock).toString());
    final quantityController = TextEditingController(
        text: (editedVariant?.quantity ?? sellerData.quantity).toString());
    
    bool isPublished = editedVariant?.isPublished ?? sellerData.isPublished;
    bool isRemove = editedVariant?.isRemove ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Satıştaki Varyasyonu Düzenle',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Varyasyon Adı
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRemove ? Colors.red[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: isRemove ? Border.all(color: Colors.red.shade200) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isRemove ? Icons.remove_shopping_cart : Icons.inventory_2_outlined, 
                        color: isRemove ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variation.variantTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: isRemove ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (variation.variantBarcode.isNotEmpty)
                              Text(
                                'Barkod: ${variation.variantBarcode}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Yayın Durumu ve Satıştan Çıkart Switchleri
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPublished ? Icons.visibility : Icons.visibility_off,
                                color: isPublished ? _successGreen : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Yayında',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isPublished,
                            onChanged: isRemove ? null : (value) {
                              setSheetState(() => isPublished = value);
                            },
                            activeColor: _successGreen,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: isRemove ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Satıştan Çıkart',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isRemove ? Colors.red : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isRemove,
                            onChanged: (value) {
                              setSheetState(() => isRemove = value);
                            },
                            activeColor: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Fiyat Alanları (Satıştan çıkartılmayacaksa göster)
                if (!isRemove) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: priceController,
                          label: 'Satış Fiyatı (TL)',
                          icon: Icons.attach_money,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: discountPriceController,
                          label: 'İndirimli Fiyat (TL)',
                          icon: Icons.local_offer_outlined,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stok ve Adet Alanları
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: stockController,
                          label: 'Stok Adedi',
                          icon: Icons.warehouse_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: quantityController,
                          label: 'Paket Adedi',
                          icon: Icons.inventory_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Kaydet Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final price = double.tryParse(priceController.text) ?? sellerData.price;
                      final discountPrice =
                          double.tryParse(discountPriceController.text) ?? sellerData.discountPrice;
                      final stock = int.tryParse(stockController.text) ?? sellerData.stock;
                      final quantity =
                          int.tryParse(quantityController.text) ?? sellerData.quantity;

                      viewModel.updateSellingVariant(
                        variation.variantID,
                        price: price,
                        discountPrice: discountPrice,
                        stock: stock,
                        quantity: quantity,
                        isPublished: isPublished,
                        isRemove: isRemove,
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRemove ? Colors.red : AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      isRemove ? 'Satıştan Çıkart' : 'Değişiklikleri Kaydet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 12),
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: GoogleFonts.poppins(fontSize: 14),
    );
  }

  Widget _buildDescriptionSection(ProductDetailData product) {
    if (product.productDesc.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ürün Açıklaması',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.productDesc,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF555555),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ProductDetailViewModel viewModel) {
    final hasSelection = viewModel.selectedVariantCount > 0;
    final hasEdited = viewModel.hasEditedSellingVariants;

    // İki buton da gösterilecekse
    if (hasSelection && hasEdited) {
      return Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Güncelle butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !viewModel.isUpdating
                    ? () => _handleUpdateSellProduct(viewModel)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: viewModel.isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Satıştakileri Güncelle (${viewModel.editedSellingVariants.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Satışa ekle butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !viewModel.isSelling
                    ? () => _handleSellProduct(viewModel)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: viewModel.isSelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Satışa Ekle (${viewModel.selectedVariantCount})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    // Sadece güncelleme varsa
    if (hasEdited) {
      return Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Düzenlenen Varyasyon",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "${viewModel.editedSellingVariants.length} Adet",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: !viewModel.isUpdating
                    ? () => _handleUpdateSellProduct(viewModel)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: viewModel.isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Güncelle',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    // Sadece satışa ekleme varsa veya hiçbiri yoksa
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasSelection ? "Seçili Varyasyon" : "Satışa Ekle",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              Text(
                hasSelection
                    ? "${viewModel.selectedVariantCount} Adet"
                    : "Varyasyon seçin",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: hasSelection && !viewModel.isSelling
                  ? () => _handleSellProduct(viewModel)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasSelection ? AppTheme.primaryColor : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: viewModel.isSelling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Satışa Ekle',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdateSellProduct(ProductDetailViewModel viewModel) async {
    final authViewModel = context.read<AuthViewModel>();
    final token = authViewModel.loginResponse?.data?.token;

    if (token == null) return;

    final success = await viewModel.updateSellProduct(token, widget.productID);

    if (success) {
      _showSnackBar(
          viewModel.successMessage ?? 'Ürün başarıyla güncellendi');
      // Geri dönünce listeyi yenilemek için true döndür
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context, true);
      });
    } else {
      _showSnackBar(viewModel.errorMessage ?? 'Bir hata oluştu', isError: true);
    }
  }

  Future<void> _handleSellProduct(ProductDetailViewModel viewModel) async {
    final authViewModel = context.read<AuthViewModel>();
    final token = authViewModel.loginResponse?.data?.token;

    if (token == null) return;

    // Fiyat kontrolü
    for (var variant in viewModel.selectedVariants) {
      if (variant.price <= 0) {
        _showSnackBar('${variant.variantTitle} için fiyat girmelisiniz',
            isError: true);
        return;
      }
    }

    final success = await viewModel.sellProduct(token, widget.productID);

    if (success) {
      _showSnackBar(
          viewModel.successMessage ?? 'Ürün başarıyla satışa eklendi');
      // Geri dönünce listeyi yenilemek için true döndür
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context, true);
      });
    } else {
      _showSnackBar(viewModel.errorMessage ?? 'Bir hata oluştu', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red : _successGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildErrorState(ProductDetailViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage!, style: GoogleFonts.poppins()),
            TextButton(
              onPressed: _loadProductDetail,
              child: const Text("Tekrar Dene"),
            )
          ],
        ),
      ),
    );
  }
}
