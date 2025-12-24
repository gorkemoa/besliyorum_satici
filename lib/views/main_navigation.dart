import 'package:flutter/material.dart';
import 'package:besliyorum_satici/views/home/home_page.dart';
import 'package:besliyorum_satici/views/order/orders_page.dart';
import 'package:besliyorum_satici/views/products/products_page.dart';
import 'package:besliyorum_satici/views/payment/payments_page.dart';
import 'package:besliyorum_satici/views/profile/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  // Her sayfa için key counter'lar - sayfa yenilendiğinde artacak
  int _homeKeyIndex = 0;
  int _ordersKeyIndex = 0;
  int _productsKeyIndex = 0;
  int _paymentsKeyIndex = 0;
  int _profileKeyIndex = 0;

  List<Widget> get _pages => [
    HomePage(key: ValueKey('home_$_homeKeyIndex')),
    OrdersPage(key: ValueKey('orders_$_ordersKeyIndex')),
    ProductsPage(key: ValueKey('products_$_productsKeyIndex')),
    PaymentsPage(key: ValueKey('payments_$_paymentsKeyIndex')),
    ProfilePage(key: ValueKey('profile_$_profileKeyIndex')),
  ];

  // Mevcut sayfayı yenile
  void _refreshCurrentPage() {
    debugPrint('🔄 [MAIN_NAVIGATION] Sayfa yenileniyor: $_currentIndex');
    setState(() {
      switch (_currentIndex) {
        case 0: // HomePage
          _homeKeyIndex++;
          break;
        case 1: // OrdersPage
          _ordersKeyIndex++;
          break;
        case 2: // ProductsPage
          _productsKeyIndex++;
          break;
        case 3: // PaymentsPage
          _paymentsKeyIndex++;
          break;
        case 4: // ProfilePage
          _profileKeyIndex++;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
            // Sayfa değiştiğinde ilgili sayfayı yenile
            _refreshCurrentPage();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Siparişler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Ürünler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Ödemeler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }
}
