import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tile_calculator_provider.dart';

class TileCalculatorScreen extends StatefulWidget {
  const TileCalculatorScreen({super.key});

  @override
  State<TileCalculatorScreen> createState() => _TileCalculatorScreenState();
}

class _TileCalculatorScreenState extends State<TileCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomLengthController = TextEditingController();
  final _roomWidthController = TextEditingController();
  final _tileLengthController = TextEditingController();
  final _tileWidthController = TextEditingController();
  final _wasteController = TextEditingController(text: '10');

  @override
  void dispose() {
    _roomLengthController.dispose();
    _roomWidthController.dispose();
    _tileLengthController.dispose();
    _tileWidthController.dispose();
    _wasteController.dispose();
    super.dispose();
  }

  void _reset(TileCalculatorProvider provider) {
    _formKey.currentState?.reset();
    _roomLengthController.clear();
    _roomWidthController.clear();
    _tileLengthController.clear();
    _tileWidthController.clear();
    _wasteController.text = '10';
    provider.reset();
  }

  String? _validateValue(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите $fieldName';
    }

    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return 'Значение должно быть больше 0';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TileCalculatorProvider(),
      child: Consumer<TileCalculatorProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Калькулятор плитки'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _reset(provider),
                  tooltip: 'Сбросить',
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildNumberField(
                                controller: _roomLengthController,
                                label: 'Длина помещения',
                                suffixText: 'см',
                                onChanged: provider.setRoomLength,
                                validator: (value) =>
                                    _validateValue(value, 'длину помещения'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _roomWidthController,
                                label: 'Ширина помещения',
                                suffixText: 'см',
                                onChanged: provider.setRoomWidth,
                                validator: (value) =>
                                    _validateValue(value, 'ширину помещения'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _tileLengthController,
                                label: 'Длина плитки',
                                suffixText: 'см',
                                onChanged: provider.setTileLength,
                                validator: (value) =>
                                    _validateValue(value, 'длину плитки'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _tileWidthController,
                                label: 'Ширина плитки',
                                suffixText: 'см',
                                onChanged: provider.setTileWidth,
                                validator: (value) =>
                                    _validateValue(value, 'ширину плитки'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _wasteController,
                                label: 'Запас',
                                suffixText: '%',
                                onChanged: provider.setWastePercent,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите запас';
                                  }

                                  final parsed = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (parsed == null || parsed < 0) {
                                    return 'Значение должно быть неотрицательным';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    provider.calculate();
                                  }
                                },
                                child: const Text('Рассчитать'),
                              ),
                              if (provider.error != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  provider.error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (provider.result != null) ...[
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Результат',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              _buildResultRow(
                                context,
                                label: 'Площадь помещения',
                                value:
                                    '${provider.result!.roomArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Площадь одной плитки',
                                value:
                                    '${provider.result!.tileArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Необходимое количество плиток',
                                value:
                                    '${provider.result!.tilesWithoutWaste} шт.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Количество с учётом запаса',
                                value: '${provider.result!.tilesWithWaste} шт.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Общая площадь покрытия',
                                value:
                                    '${provider.result!.totalCoveredArea.toStringAsFixed(2)} м²',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String suffixText,
    required void Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffixText),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildResultRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
