import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../auth/login_page.dart';
import 'widgets/seller_product_card.dart';
import 'widgets/catalog_product_card.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _sellerScrollController = ScrollController();
  final ScrollController _catalogScrollController = ScrollController();
  int? _selectedCatID;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _sellerScrollController.addListener(_onSellerScroll);
    _catalogScrollController.addListener(_onCatalogScroll);

    Provider.of<ProductViewModel>(context, listen: false).resetState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _sellerScrollController.removeListener(_onSellerScroll);
    _catalogScrollController.removeListener(_onCatalogScroll);
    _sellerScrollController.dispose();
    _catalogScrollController.dispose();
    super.dispose();
  }

  // --- LOGIC FUNCTIONS (Değişmedi) ---
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final token = _getToken();
    if (token == null) return;
    final vm = Provider.of<ProductViewModel>(context, listen: false);
    if (_tabController.index == 0 && vm.sellerProducts.isEmpty) {
      vm.getSellerProducts(token);
    } else if (_tabController.index == 1 && vm.catalogProducts.isEmpty) {
      vm.getCatalogProducts(token);
    }
  }

  void _loadInitialData() {
    final token = _getToken();
    if (token == null) return;
    final vm = Provider.of<ProductViewModel>(context, listen: false);
    vm.getSellerProducts(token);
    vm.getCatalogProducts(token);
    vm.getCategories(token);
  }

  String? _getToken() {
    return Provider.of<AuthViewModel>(context, listen: false).loginResponse?.data?.token;
  }

  void _onSellerScroll() {
    if (_sellerScrollController.position.pixels >= _sellerScrollController.position.maxScrollExtent - 200) {
      final token = _getToken();
      if (token != null) Provider.of<ProductViewModel>(context, listen: false).loadMoreSellerProducts(token);
    }
  }

  void _onCatalogScroll() {
    if (_catalogScrollController.position.pixels >= _catalogScrollController.position.maxScrollExtent - 200) {
      final token = _getToken();
      if (token != null) Provider.of<ProductViewModel>(context, listen: false).loadMoreCatalogProducts(token);
    }
  }

  void _onSearch(String query) {
    final token = _getToken();
    if (token == null) return;
    final vm = Provider.of<ProductViewModel>(context, listen: false);
    if (_tabController.index == 0) {
      vm.filterSellerProducts(token, search: query, catID: _selectedCatID);
    } else {
      vm.filterCatalogProducts(token, search: query, catID: _selectedCatID);
    }
  }

  Future<void> _onRefresh() async {
    final token = _getToken();
    if (token == null) return;
    final vm = Provider.of<ProductViewModel>(context, listen: false);
    if (_tabController.index == 0) {
      await vm.getSellerProducts(token, refresh: true, catID: _selectedCatID, search: _searchController.text);
    } else {
      await vm.getCatalogProducts(token, refresh: true, catID: _selectedCatID, search: _searchController.text);
    }
  }

  void _handleLogout(String? errorMessage) {
    if (errorMessage == '403_LOGOUT' && !_isLoggingOut) {
      _isLoggingOut = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      });
    }
  }

  // --- UI KISMI: BURASI TAMAMEN DEĞİŞTİ ---
  @override
  Widget build(BuildContext context) {
    // Scaffold'da appBar YOK. Body'yi SafeArea ile başlatıyoruz.
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 1. KISIM: SABİT KAFA KISMI (Header)
          // Kırmızı Başlık + Arama + Filtre + TabBar hepsi burada
          _buildFixedHeader(),

          // 2. KISIM: KAYDIRILABİLİR LİSTE ALANI
          // Expanded, kalan tüm boşluğu alır.
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSellerProductsTab(),
                _buildCatalogProductsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      color: Colors.white, // Alt kısımdaki beyaz zemin
      child: Column(
        mainAxisSize: MainAxisSize.min, // İçeriği kadar yer kaplar
        children: [
          // A) Kırmızı Başlık Alanı (Özel AppBar)
          Container(
            width: double.infinity,
            color: AppTheme.primaryColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10, // Status bar boşluğu
              bottom: 20,
            ),
            child: Center(
              child: Text(
                'Ürünlerim',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // B) Arama Çubuğu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ürün ara...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: Colors.grey[400], size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                onSubmitted: _onSearch,
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),

          // C) Kategori Filtresi
          _buildCategoryFilter(),

          // D) Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(height: 40, text: 'Ürünlerim'),
                Tab(height: 40, text: 'Katalog'),
              ],
            ),
          ),
          const SizedBox(height: 10), // TabBar altı hafif boşluk
        ],
      ),
    );
  }

  // --- HELPER WIDGETS (Aynen kaldı) ---

  Widget _buildCategoryFilter() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isCategoriesLoading && viewModel.categories.isEmpty) {
          return const SizedBox(
            height: 48,
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        if (viewModel.categories.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 15),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(id: null, name: 'Tümü', isSelected: _selectedCatID == null);
              }
              final category = viewModel.categories[index - 1];
              return _buildCategoryChip(id: category.catID, name: category.catName, isSelected: _selectedCatID == category.catID);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({required int? id, required String name, required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() { _selectedCatID = id; });
          _onCategorySelected(id);
        },
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.85)])
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!, width: isSelected ? 0 : 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white), const SizedBox(width: 6)],
              Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(int? catID) {
    final token = _getToken();
    if (token == null) return;
    final vm = Provider.of<ProductViewModel>(context, listen: false);
    if (_tabController.index == 0) {
      vm.getSellerProducts(token, catID: catID, search: _searchController.text, refresh: true);
    } else {
      vm.getCatalogProducts(token, catID: catID, search: _searchController.text, refresh: true);
    }
  }

  Widget _buildSellerProductsTab() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        _handleLogout(viewModel.sellerProductsErrorMessage);
        if (viewModel.isSellerProductsLoading && viewModel.sellerProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        if (viewModel.sellerProductsErrorMessage != null && viewModel.sellerProductsErrorMessage != '403_LOGOUT') {
           return _buildErrorView(onRetry: () { final t = _getToken(); if (t!=null) viewModel.getSellerProducts(t, refresh: true); });
        }
        if (viewModel.sellerProducts.isEmpty) {
          return _buildEmptyView(icon: Icons.inventory_2_outlined, title: 'Henüz ürününüz yok', subtitle: 'Katalogdan ürün ekleyin');
        }
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryColor,
          child: GridView.builder(
            controller: _sellerScrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.53, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: viewModel.sellerProducts.length + (viewModel.isSellerProductsLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= viewModel.sellerProducts.length) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.primaryColor)));
              final product = viewModel.sellerProducts[index];
              return SellerProductCard(
                product: product,
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(productID: product.productID)));
                  if (result == true && mounted) _onRefresh();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCatalogProductsTab() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        _handleLogout(viewModel.catalogProductsErrorMessage);
        if (viewModel.isCatalogProductsLoading && viewModel.catalogProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        if (viewModel.catalogProductsErrorMessage != null && viewModel.catalogProductsErrorMessage != '403_LOGOUT') {
           return _buildErrorView(onRetry: () { final t = _getToken(); if (t!=null) viewModel.getCatalogProducts(t, refresh: true); });
        }
        if (viewModel.catalogProducts.isEmpty) {
          return _buildEmptyView(icon: Icons.category_outlined, title: 'Katalog boş', subtitle: 'Katalogda ürün yok');
        }
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryColor,
          child: GridView.builder(
            controller: _catalogScrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.55, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: viewModel.catalogProducts.length + (viewModel.isCatalogProductsLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
               if (index >= viewModel.catalogProducts.length) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.primaryColor)));
              final product = viewModel.catalogProducts[index];
              return CatalogProductCard(
                product: product,
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(productID: product.productID)));
                  if (result == true && mounted) _onRefresh();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorView({required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text('Bir hata oluştu', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          TextButton(onPressed: onRetry, child: Text('Tekrar Dene')),
        ],
      ),
    );
  }

  Widget _buildEmptyView({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey[600])),
        ],
      ),
    );
  }
}