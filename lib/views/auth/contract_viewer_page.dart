import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/auth/contract_model.dart';
import '../../services/contract_service.dart';
import '../../core/constants/app_constants.dart';

enum ContractType { seller, kvkk, iyzico }

class ContractViewerPage extends StatefulWidget {
  final ContractType contractType;

  const ContractViewerPage({super.key, required this.contractType});

  @override
  State<ContractViewerPage> createState() => _ContractViewerPageState();
}

class _ContractViewerPageState extends State<ContractViewerPage> {
  final ContractService _contractService = ContractService();
  bool _isLoading = true;
  String? _errorMessage;
  ContractModel? _contract;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    if (widget.contractType == ContractType.iyzico) {
      _initWebView();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ContractModel? contract;
      if (widget.contractType == ContractType.seller) {
        contract = await _contractService.getSellerPolicy();
      } else if (widget.contractType == ContractType.kvkk) {
        contract = await _contractService.getKvkkPolicy();
      }

      setState(() {
        _contract = contract;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = 'Sayfa yüklenemedi';
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(Endpoints.iyzicoPolicy));
  }

  String get _title {
    switch (widget.contractType) {
      case ContractType.seller:
        return 'Üyelik Sözleşmesi';
      case ContractType.kvkk:
        return 'KVKK Aydınlatma Metni';
      case ContractType.iyzico:
        return 'iyzico Sözleşmesi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          _title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Sözleşme yüklenemedi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContract,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    // iyzico için WebView
    if (widget.contractType == ContractType.iyzico &&
        _webViewController != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
        ],
      );
    }

    // Diğer sözleşmeler için metin görünümü
    if (_contract != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _contract!.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // İçerik
            Text(
              _contract!.plainContent,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Sözleşmeyi modal bottom sheet olarak gösterir
void showContractBottomSheet({
  required BuildContext context,
  required ContractType contractType,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ContractViewerPage(contractType: contractType),
    ),
  );
}
