import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/coin.dart';
import '../models/holding.dart';
import 'package:cached_network_image/cached_network_image.dart';

void showTradeModal(
  BuildContext context, {
  required Coin coin,
  Holding? existingHolding,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TradeModal(coin: coin, existingHolding: existingHolding),
  );
}

class TradeModal extends StatefulWidget {
  final Coin coin;
  final Holding? existingHolding;

  const TradeModal({super.key, required this.coin, this.existingHolding});

  @override
  State<TradeModal> createState() => _TradeModalState();
}

class _TradeModalState extends State<TradeModal> {
  late bool _isBuying = true;
  final _amountController = TextEditingController();
  double _usdAmount = 0;
  double _coinAmount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final input = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _usdAmount = input;
      _coinAmount = input / widget.coin.currentPrice;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildCoinHeader(),
          const SizedBox(height: 24),

          _buildToggle(),
          const SizedBox(height: 24),

          _buildAmountInput(),
          const SizedBox(height: 8),

          if (_coinAmount > 0)
            Text(
              '≈ ${_coinAmount.toStringAsFixed(6)} ${widget.coin.symbol.toUpperCase()}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          const SizedBox(height: 8),

          _buildAvailableInfo(),
          const SizedBox(height: 16),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),

          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildCoinHeader() {
    return Row(
      children: [
        CachedNetworkImage(
          imageUrl: widget.coin.image,
          width: 40,
          height: 40,
          errorWidget: (context, url, error) =>
              const Icon(Icons.currency_bitcoin),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.coin.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${widget.coin.currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Buy',
              isSelected: _isBuying,
              selectedColor: Colors.green,
              onTap: () => setState(() {
                _isBuying = true;
                _errorMessage = null;
              }),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Sell',
              isSelected: !_isBuying,
              selectedColor: Colors.red,
              onTap: () => setState(() {
                _isBuying = false;
                _errorMessage = null;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: 'Amount in USD',
        prefixText: '\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAvailableInfo() {
    if (_isBuying) {
      return const Text(
        'Available: \$0.00',
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    } else {
      final holdingAmount = widget.existingHolding?.amount ?? 0;
      return Text(
        'Holdings: $holdingAmount ${widget.coin.symbol.toUpperCase()}',
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      );
    }
  }

  Widget _buildConfirmButton() {
    final label = _isBuying
        ? 'Buy ${widget.coin.symbol.toUpperCase()}'
        : 'Sell ${widget.coin.symbol.toUpperCase()}';

    final color = _isBuying ? Colors.green : Colors.red;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _usdAmount > 0 ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Private toggle button widget
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: selectedColor, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
