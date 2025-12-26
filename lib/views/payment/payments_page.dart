import 'package:besliyorum_satici/core/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/payment_viewmodel.dart';
import '../../models/payment/payment_model.dart';
import '../auth/login_page.dart';
import 'payment_detail_page.dart';

enum PaymentSortOption { newest, oldest, amountAsc, amountDesc }

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PaymentSortOption _selectedSort = PaymentSortOption.newest;

  // Filter Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  // Active Filters
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  double? _filterMinAmount;
  double? _filterMaxAmount;
  bool _isFilterActive = false;
  bool _showFilterAction = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showFilterAction = _tabController.index == 1;
      });
    });

    final paymentViewModel = Provider.of<PaymentViewModel>(
      context,
      listen: false,
    );
    paymentViewModel.resetState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.contains('.')) {
        final parts = dateStr.split('.');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } else if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    } catch (_) {}
    return null;
  }

  void _loadPayments() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final paymentViewModel = Provider.of<PaymentViewModel>(
      context,
      listen: false,
    );

    final token = authViewModel.loginResponse?.data?.token;

    if (token != null) {
      paymentViewModel.getPayments(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Ödemeler',
          style: GoogleFonts.poppins(
            color: AppTheme.secondaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.secondaryColor),
        actions: [
          if (_showFilterAction)
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: _isFilterActive
                        ? AppTheme.secondaryColor
                        : AppTheme.secondaryColor.withOpacity(0.7),
                  ),
                  onPressed: _showFilterBottomSheet,
                ),
                if (_isFilterActive)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Bekleyen'),
                  Tab(text: 'Geçmiş'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<PaymentViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.errorMessage == '403_LOGOUT') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  });
                  return const SizedBox.shrink();
                }

                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                if (viewModel.errorMessage != null) {
                  return _buildErrorState(viewModel.errorMessage!);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentList(
                      payments: viewModel.futurePayments,
                      totalAmount: viewModel.futurePaymentsTotalAmount,
                      totalItems: viewModel.futurePaymentsTotalItems,
                      emptyMessage: 'Bekleyen ödeme bulunmuyor.',
                      isFuture: true,
                    ),
                    _buildPaymentList(
                      payments: viewModel.pastPayments,
                      totalAmount: viewModel.pastPaymentsTotalAmount,
                      totalItems: viewModel.pastPaymentsTotalItems,
                      emptyMessage: 'Geçmiş ödeme bulunmuyor.',
                      isFuture: false,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 32, color: AppTheme.errorColor),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadPayments,
              child: Text(
                'Tekrar Dene',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList({
    required List<Payment> payments,
    required String totalAmount,
    required int totalItems,
    required String emptyMessage,
    required bool isFuture,
  }) {
    List<Payment> displayedPayments = List.from(payments);

    // Apply Filters for Past Payments
    if (!isFuture) {
      // Filter logic only for past payments
      if (_isFilterActive) {
        displayedPayments = displayedPayments.where((payment) {
          final date = _parseDate(payment.payDate);
          if (date == null) return false;

          // Date Range
          if (_filterStartDate != null && date.isBefore(_filterStartDate!))
            return false;
          if (_filterEndDate != null &&
              date.isAfter(_filterEndDate!.add(const Duration(days: 1))))
            return false;

          // Amount Range
          // Assuming 'payAmount' format is like "1.250,50 TL" or similar.
          // Needs parsing login.
          double? amount = _parseAmount(payment.payAmount);
          if (amount != null) {
            if (_filterMinAmount != null && amount < _filterMinAmount!)
              return false;
            if (_filterMaxAmount != null && amount > _filterMaxAmount!)
              return false;
          }

          return true;
        }).toList();
      }

      // Sorting
      displayedPayments.sort((a, b) {
        final dateA = _parseDate(a.payDate) ?? DateTime(0);
        final dateB = _parseDate(b.payDate) ?? DateTime(0);
        final amountA = _parseAmount(a.payAmount) ?? 0;
        final amountB = _parseAmount(b.payAmount) ?? 0;

        switch (_selectedSort) {
          case PaymentSortOption.newest:
            return dateB.compareTo(dateA);
          case PaymentSortOption.oldest:
            return dateA.compareTo(dateB);
          case PaymentSortOption.amountDesc:
            return amountB.compareTo(amountA);
          case PaymentSortOption.amountAsc:
            return amountA.compareTo(amountB);
        }
      });
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFuture ? 'TOPLAM BEKLEYEN' : 'TOPLAM ÖDENEN',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalAmount,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (isFuture ? AppTheme.primaryColor : AppTheme.successColor)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$totalItems Adet',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isFuture
                        ? AppTheme.primaryColor
                        : AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: displayedPayments.isEmpty
              ? _buildEmptyState(emptyMessage)
              : RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: () async => _loadPayments(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: displayedPayments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _buildPaymentCard(displayedPayments[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 32, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final isPaid = payment.isPaid;
    final statusColor = isPaid ? AppTheme.successColor : AppTheme.primaryColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailPage(
              paymentID: payment.paymentID,
              payDate: payment.payDate,
              orderID: payment.orderID,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPaid ? Icons.check_circle_outline : Icons.access_time,
                color: statusColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sipariş #${payment.orderID}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    payment.payDate,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payment.payAmount,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods for Filtering

  double? _parseAmount(String amountStr) {
    try {
      String clean = amountStr.replaceAll('TL', '').replaceAll(' ', '');
      clean = clean.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(clean);
    } catch (_) {
      return null;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ödemeleri Filtrele',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort Section
                  Text(
                    'Sıralama',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip(
                        setModalState,
                        'En Yeni',
                        PaymentSortOption.newest,
                      ),
                      _buildSortChip(
                        setModalState,
                        'En Eski',
                        PaymentSortOption.oldest,
                      ),
                      _buildSortChip(
                        setModalState,
                        'Tutar Azalan',
                        PaymentSortOption.amountDesc,
                      ),
                      _buildSortChip(
                        setModalState,
                        'Tutar Artan',
                        PaymentSortOption.amountAsc,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Date Range
                  Text(
                    'Tarih Aralığı',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          controller: _startDateController,
                          label: 'Başlangıç',
                          hint: 'gg.aa.yyyy',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          controller: _endDateController,
                          label: 'Bitiş',
                          hint: 'gg.aa.yyyy',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount Range
                  Text(
                    'Tutar Aralığı (TL)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          controller: _minAmountController,
                          hint: 'Min',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          controller: _maxAmountController,
                          hint: 'Max',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Clear
                            _startDateController.clear();
                            _endDateController.clear();
                            _minAmountController.clear();
                            _maxAmountController.clear();
                            setState(() {
                              _filterStartDate = null;
                              _filterEndDate = null;
                              _filterMinAmount = null;
                              _filterMaxAmount = null;
                              _isFilterActive = false;
                              _selectedSort = PaymentSortOption.newest;
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Temizle',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply
                            setState(() {
                              _filterStartDate = _parseDate(
                                _startDateController.text,
                              );
                              _filterEndDate = _parseDate(
                                _endDateController.text,
                              );
                              _filterMinAmount = double.tryParse(
                                _minAmountController.text,
                              );
                              _filterMaxAmount = double.tryParse(
                                _maxAmountController.text,
                              );
                              _isFilterActive = true;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Uygula',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortChip(
    StateSetter setModalState,
    String label,
    PaymentSortOption option,
  ) {
    final isSelected = _selectedSort == option;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          setState(() {
            // Update main state as well so it persists if we reopen or apply
            _selectedSort = option;
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _showCupertinoDatePicker(controller),
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          color: Colors.grey[400],
          size: 18,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  void _showCupertinoDatePicker(TextEditingController controller) {
    DateTime selectedDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      selectedDate = _parseDate(controller.text) ?? DateTime.now();
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = selectedDate;
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'İptal',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Tarih Seçin',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Tamam',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        final day = tempDate.day.toString().padLeft(2, '0');
                        final month = tempDate.month.toString().padLeft(2, '0');
                        final year = tempDate.year.toString();
                        controller.text = '$day.$month.$year';
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime.now().add(const Duration(days: 365)),
                  dateOrder: DatePickerDateOrder.dmy,
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
