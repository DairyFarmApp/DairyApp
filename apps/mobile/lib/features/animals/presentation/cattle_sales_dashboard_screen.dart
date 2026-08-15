import 'package:dairycare_mobile/core/widgets/app_surface.dart';
import 'package:dairycare_mobile/features/animals/data/animal_sales_repository.dart';
import 'package:flutter/material.dart';
import 'package:dairycare_mobile/core/formatting/pkr.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CattleSalesDashboardScreen extends ConsumerWidget {
  const CattleSalesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(animalSalesProvider);
    final purchasesAsync = ref.watch(animalPurchasesProvider);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Sales & Purchases',
                  subtitle:
                      'Manage cattle sales and purchase history across all farms',
                  actions: [
                    FilledButton.icon(
                      onPressed: () => context.push('/animals/purchases/new'),
                      icon: const Icon(Icons.add_business_rounded),
                      label: const Text('New Purchase'),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.push('/animals/sales/new'),
                      icon: const Icon(Icons.sell_rounded),
                      label: const Text('New Sale'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Total Sales Revenue',
                          value: salesAsync.when(
                            data: (data) => formatPkr(
                              data.fold<double>(
                                0,
                                (total, sale) => total + sale.netRevenue,
                              ),
                            ),
                            loading: () => '...',
                            error: (_, _) => 'Error',
                          ),
                          icon: Icons.payments_rounded,
                          solidBackground: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          label: 'Cattle Sold',
                          value: salesAsync.when(
                            data: (data) => data.length.toString(),
                            loading: () => '...',
                            error: (_, _) => 'Error',
                          ),
                          icon: Icons.sell_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          label: 'Cattle Purchased',
                          value: purchasesAsync.when(
                            data: (data) => data.length.toString(),
                            loading: () => '...',
                            error: (_, _) => 'Error',
                          ),
                          icon: Icons.add_shopping_cart_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sales Table
                SectionCard(
                  title: 'Recent Sales',
                  child: salesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (sales) {
                      if (sales.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No recent sales found.')),
                        );
                      }
                      return Card(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Animal')),
                            DataColumn(label: Text('Buyer')),
                            DataColumn(label: Text('Price (PKR)')),
                            DataColumn(label: Text('Net revenue (PKR)')),
                          ],
                          rows: sales.map((sale) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat.yMMMd().format(sale.saleDate),
                                  ),
                                ),
                                DataCell(
                                  InkWell(
                                    onTap: sale.animalId == null
                                        ? null
                                        : () => context.push(
                                            '/animals/${sale.animalId}',
                                          ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sale.animal?.animalNumber ??
                                              'View Animal',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          size: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(Text(sale.buyer ?? '-')),
                                DataCell(Text(formatPkr(sale.salePrice))),
                                DataCell(Text(formatPkr(sale.netRevenue))),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Purchases Table
                SectionCard(
                  title: 'Recent Purchases',
                  child: purchasesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (purchases) {
                      if (purchases.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('No recent purchases found.'),
                          ),
                        );
                      }
                      return Card(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Animal')),
                            DataColumn(label: Text('Supplier')),
                            DataColumn(label: Text('Cost (PKR)')),
                          ],
                          rows: purchases.map((purchase) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat.yMMMd().format(
                                      purchase.purchaseDate,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  InkWell(
                                    onTap: purchase.animalId == null
                                        ? null
                                        : () => context.push(
                                            '/animals/${purchase.animalId}',
                                          ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          purchase.animal?.animalNumber ??
                                              'View Animal',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          size: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(Text(purchase.supplier ?? '-')),
                                DataCell(Text(formatPkr(purchase.totalCost))),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
