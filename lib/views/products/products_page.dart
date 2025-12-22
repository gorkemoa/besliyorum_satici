import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../auth/login_page.dart';
import 'widgets/seller_product_card.dart';
import 'widgets/catalog_product_card.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _sellerScrollController.addListener(_onSellerScroll);
    _catalogScrollController.addListener(_onCatalogScroll);

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

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final token = _getToken();
    if (token == null) return;

    final productViewModel = Provider.of<ProductViewModel>(
      context,
      listen: false,
    );

    if (_tabController.index == 0 && productViewModel.sellerProducts.isEmpty) {
      productViewModel.getSellerProducts(token);
    } else if (_tabController.index == 1 &&
        productViewModel.catalogProducts.isEmpty) {
      productViewModel.getCatalogProducts(token);
    }
  }

  void _loadInitialData() {
    final token = _getToken();
    if (token == null) return;

    final productViewModel = Provider.of<ProductViewModel>(
      context,
      listen: false,
    );
    productViewModel.getSellerProducts(token);
    productViewModel.getCatalogProducts(token);
    productViewModel.getCategories(token);
  }

  String? _getToken() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    return authViewModel.loginResponse?.data?.token;
  }

  void _onSellerScroll() {
    if (_sellerScrollController.position.pixels >=
        _sellerScrollController.position.maxScrollExtent - 200) {
      final token = _getToken();
      if (token != null) {
        Provider.of<ProductViewModel>(
          context,
          listen: false,
        ).loadMoreSellerProducts(token);
      }
    }
  }

  void _onCatalogScroll() {
    if (_catalogScrollController.position.pixels >=
        _catalogScrollController.position.maxScrollExtent - 200) {
      final token = _getToken();
      if (token != null) {
        Provider.of<ProductViewModel>(
          context,
          listen: false,
        ).loadMoreCatalogProducts(token);
      }
    }
  }

  void _onSearch(String query) {
    final token = _getToken();
    if (token == null) return;

    final productViewModel = Provider.of<ProductViewModel>(
      context,
      listen: false,
    );

    if (_tabController.index == 0) {
      productViewModel.filterSellerProducts(
        token,
        search: query,
        catID: _selectedCatID,
      );
    } else {
      productViewModel.filterCatalogProducts(
        token,
        search: query,
        catID: _selectedCatID,
      );
    }
  }

  Future<void> _onRefresh() async {
    final token = _getToken();
    if (token == null) return;

    final productViewModel = Provider.of<ProductViewModel>(
      context,
      listen: false,
    );

    if (_tabController.index == 0) {
      await productViewModel.getSellerProducts(
        token,
        refresh: true,
        catID: _selectedCatID,
        search: _searchController.text,
      );
    } else {
      await productViewModel.getCatalogProducts(
        token,
        refresh: true,
        catID: _selectedCatID,
        search: _searchController.text,
      );
    }
  }

  void _handleLogout(String? errorMessage) {
    if (errorMessage == '403_LOGOUT') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: Text(
                'Ürünlerim',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(170),
                child: Column(
                  children: [
                    // Arama Çubuğu
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Ürün ara...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[400],
                              size: 22,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearch('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 14),
                          onSubmitted: _onSearch,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                    ),

                    // Kategori Filtresi
                    _buildCategoryFilter(),

                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppTheme.primaryColor,
                        indicatorWeight: 3,
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Ürünlerim'),
                          Tab(text: 'Katalog'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildSellerProductsTab(), _buildCatalogProductsTab()],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isCategoriesLoading && viewModel.categories.isEmpty) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (viewModel.categories.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  id: null,
                  name: 'Tümü',
                  isSelected: _selectedCatID == null,
                );
              }

              final category = viewModel.categories[index - 1];
              return _buildCategoryChip(
                id: category.catID,
                name: category.catName,
                isSelected: _selectedCatID == category.catID,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required int? id,
    required String name,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCatID = id;
            });
            _onCategorySelected(id);
          }
        },
        selectedColor: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(int? catID) {
    final token = _getToken();
    if (token == null) return;

    final productViewModel = Provider.of<ProductViewModel>(
      context,
      listen: false,
    );

    if (_tabController.index == 0) {
      productViewModel.getSellerProducts(
        token,
        catID: catID,
        search: _searchController.text,
        refresh: true,
      );
    } else {
      productViewModel.getCatalogProducts(
        token,
        catID: catID,
        search: _searchController.text,
        refresh: true,
      );
    }
  }

  Widget _buildSellerProductsTab() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        _handleLogout(viewModel.sellerProductsErrorMessage);

        if (viewModel.isSellerProductsLoading &&
            viewModel.sellerProducts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (viewModel.sellerProductsErrorMessage != null &&
            viewModel.sellerProductsErrorMessage != '403_LOGOUT') {
          return _buildErrorView(
            onRetry: () {
              final token = _getToken();
              if (token != null) {
                viewModel.getSellerProducts(token, refresh: true);
              }
            },
          );
        }

        if (viewModel.sellerProducts.isEmpty) {
          return _buildEmptyView(
            icon: Icons.inventory_2_outlined,
            title: 'Henüz ürününüz yok',
            subtitle: 'Katalogdan ürün ekleyerek satışa başlayın',
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryColor,
          child: GridView.builder(
            controller: _sellerScrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.53,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount:
                viewModel.sellerProducts.length +
                (viewModel.isSellerProductsLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= viewModel.sellerProducts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              }

              final product = viewModel.sellerProducts[index];
              return SellerProductCard(product: product);
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

        if (viewModel.isCatalogProductsLoading &&
            viewModel.catalogProducts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (viewModel.catalogProductsErrorMessage != null &&
            viewModel.catalogProductsErrorMessage != '403_LOGOUT') {
          return _buildErrorView(
            onRetry: () {
              final token = _getToken();
              if (token != null) {
                viewModel.getCatalogProducts(token, refresh: true);
              }
            },
          );
        }

        if (viewModel.catalogProducts.isEmpty) {
          return _buildEmptyView(
            icon: Icons.category_outlined,
            title: 'Katalog boş',
            subtitle: 'Şu anda katalogda ürün bulunmuyor',
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryColor,
          child: GridView.builder(
            controller: _catalogScrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount:
                viewModel.catalogProducts.length +
                (viewModel.isCatalogProductsLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= viewModel.catalogProducts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              }

              final product = viewModel.catalogProducts[index];
              return CatalogProductCard(product: product);
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Bir şeyler ters gitti',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ürünler yüklenirken bir hata oluştu',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(
              'Tekrar Dene',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
