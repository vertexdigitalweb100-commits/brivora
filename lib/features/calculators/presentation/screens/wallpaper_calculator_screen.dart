import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_calculator_provider.dart';

class WallpaperCalculatorScreen extends StatefulWidget {
  const WallpaperCalculatorScreen({super.key});

  @override
  State<WallpaperCalculatorScreen> createState() =>
      _WallpaperCalculatorScreenState();
}

class _WallpaperCalculatorScreenState extends State<WallpaperCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomLengthController = TextEditingController();
  final _roomWidthController = TextEditingController();
  final _ceilingHeightController = TextEditingController();
  final _rollWidthController = TextEditingController();
  final _rollLengthController = TextEditingController();
  final _doorCountController = TextEditingController(text: '0');
  final _doorWidthController = TextEditingController(text: '0');
  final _windowCountController = TextEditingController(text: '0');
  final _windowWidthController = TextEditingController(text: '0');
  final _windowHeightController = TextEditingController(text: '0');
  final _wasteController = TextEditingController(text: '10');

  @override
  void dispose() {
    _roomLengthController.dispose();
    _roomWidthController.dispose();
    _ceilingHeightController.dispose();
    _rollWidthController.dispose();
    _rollLengthController.dispose();
    _doorCountController.dispose();
    _doorWidthController.dispose();
    _windowCountController.dispose();
    _windowWidthController.dispose();
    _windowHeightController.dispose();
    _wasteController.dispose();
    super.dispose();
  }

  void _reset(WallpaperCalculatorProvider provider) {
    _formKey.currentState?.reset();
    _roomLengthController.clear();
    _roomWidthController.clear();
    _ceilingHeightController.clear();
    _rollWidthController.clear();
    _rollLengthController.clear();
    _doorCountController.text = '0';
    _doorWidthController.text = '0';
    _windowCountController.text = '0';
    _windowWidthController.text = '0';
    _windowHeightController.text = '0';
    _wasteController.text = '10';
    provider.reset();
  }

  String? _validatePositive(
    String? value,
    String label, {
    bool allowZero = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите $label';
    }

    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return 'Значение должно быть ${allowZero ? 'неотрицательным' : 'больше 0'}';
    }
    if (!allowZero && parsed <= 0) {
      return 'Значение должно быть больше 0';
    }
    return null;
  }

  String? _validateInteger(
    String? value,
    String label, {
    bool allowZero = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите $label';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return 'Значение должно быть целым и неотрицательным';
    }
    if (!allowZero && parsed <= 0) {
      return 'Значение должно быть больше 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WallpaperCalculatorProvider(),
      child: Consumer<WallpaperCalculatorProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Калькулятор обоев'),
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
                                label: 'Длина комнаты',
                                suffixText: 'м',
                                onChanged: provider.setRoomLength,
                                validator: (value) =>
                                    _validatePositive(value, 'длину комнаты'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _roomWidthController,
                                label: 'Ширина комнаты',
                                suffixText: 'м',
                                onChanged: provider.setRoomWidth,
                                validator: (value) =>
                                    _validatePositive(value, 'ширину комнаты'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _ceilingHeightController,
                                label: 'Высота потолка',
                                suffixText: 'м',
                                onChanged: provider.setCeilingHeight,
                                validator: (value) =>
                                    _validatePositive(value, 'высоту потолка'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _rollWidthController,
                                label: 'Ширина рулона',
                                suffixText: 'м',
                                onChanged: provider.setRollWidth,
                                validator: (value) =>
                                    _validatePositive(value, 'ширину рулона'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _rollLengthController,
                                label: 'Длина рулона',
                                suffixText: 'м',
                                onChanged: provider.setRollLength,
                                validator: (value) =>
                                    _validatePositive(value, 'длину рулона'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _doorCountController,
                                label: 'Количество дверей',
                                suffixText: 'шт.',
                                onChanged: provider.setDoorCount,
                                validator: (value) => _validateInteger(
                                  value,
                                  'количество дверей',
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _doorWidthController,
                                label: 'Ширина двери',
                                suffixText: 'м',
                                onChanged: provider.setDoorWidth,
                                validator: (value) => _validatePositive(
                                  value,
                                  'ширину двери',
                                  allowZero: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _windowCountController,
                                label: 'Количество окон',
                                suffixText: 'шт.',
                                onChanged: provider.setWindowCount,
                                validator: (value) =>
                                    _validateInteger(value, 'количество окон'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _windowWidthController,
                                label: 'Ширина окна',
                                suffixText: 'м',
                                onChanged: provider.setWindowWidth,
                                validator: (value) => _validatePositive(
                                  value,
                                  'ширину окна',
                                  allowZero: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _windowHeightController,
                                label: 'Высота окна',
                                suffixText: 'м',
                                onChanged: provider.setWindowHeight,
                                validator: (value) => _validatePositive(
                                  value,
                                  'высоту окна',
                                  allowZero: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _wasteController,
                                label: 'Запас материала',
                                suffixText: '%',
                                onChanged: provider.setWastePercent,
                                validator: (value) => _validatePositive(
                                  value,
                                  'запас материала',
                                  allowZero: true,
                                ),
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
                                label: 'Площадь стен',
                                value:
                                    '${provider.result!.wallArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Площадь дверей',
                                value:
                                    '${provider.result!.doorArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Площадь окон',
                                value:
                                    '${provider.result!.windowArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Полезная площадь',
                                value:
                                    '${provider.result!.usableWallArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Полос с одного рулона',
                                value: '${provider.result!.stripsPerRoll} шт.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Необходимое количество полотен',
                                value: '${provider.result!.requiredStrips} шт.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Необходимое количество рулонов',
                                value: '${provider.result!.rolls} шт.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Рулонов с запасом',
                                value: '${provider.result!.rollsWithWaste} шт.',
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
