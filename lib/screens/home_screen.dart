import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lookup/generated/app_localizations.dart';
import 'package:lookup/providers/auth_provider.dart';
import 'package:lookup/providers/transaction_provider.dart';
import 'package:lookup/screens/add_transaction_screen.dart';
import 'package:lookup/screens/profile_screen.dart';
import 'package:lookup/screens/statistics_screen.dart';
import 'package:lookup/screens/transactions_screen.dart';
import 'package:lookup/widgets/bottom_nav_bar.dart';
import 'package:lookup/widgets/transaction_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  void _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await transactionProvider.loadTransactions(authProvider.currentUser!.id!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void _onNavigationTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeContent(),
          const TransactionsScreen(),
          const StatisticsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTapped,
      ),

      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final balance = transactionProvider.balance;
        final income = transactionProvider.totalIncome;
        final expense = transactionProvider.totalExpense;
        final recentTransactions = transactionProvider.filteredTransactions
            .take(5)
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );

            if (authProvider.currentUser != null) {
              await transactionProvider.loadTransactions(
                authProvider.currentUser!.id!,
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          '${AppLocalizations.of(context)!.homeGreet} 👋',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          Provider.of<AuthProvider>(
                                context,
                              ).currentUser?.username ??
                              'User',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DateFormat(
                              'MMMM yyyy',
                            ).format(transactionProvider.selectedDate),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.totalBalance,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'XAF: ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCardInfoCard(
                            AppLocalizations.of(context)!.income,
                            income,
                            Icons.arrow_upward,
                            Colors.green,
                          ),
                          Container(
                            width: 1,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildCardInfoCard(
                            AppLocalizations.of(context)!.expense,
                            expense,
                            Icons.arrow_downward,
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.recentTransactions,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1;
                        });

                        _pageController.animateToPage(
                          1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.seeAll,
                        style: TextStyle(color: Color(0xFF264444)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (recentTransactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_rounded,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.noTransactions,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddTransactionScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.addFirstTransaction,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, index) {
                      return TransactionCard(
                        transaction: recentTransactions[index],
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(
                                transaction: recentTransactions[index],
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadData();
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardInfoCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            // Icon(icon, color: color, size: 20),
            Container(
              // width: 30,
              // height: 30,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'XAF: ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
