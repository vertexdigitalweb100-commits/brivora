import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../projects/domain/models/project.dart';
import '../providers/laminate_calculator_provider.dart';
import '../widgets/add_to_estimate_button.dart';

class LaminateCalculatorScreen extends StatefulWidget {
  final Project? project;

  const LaminateCalculatorScreen({super.key, this.project});

  @override
  State<LaminateCalculatorScreen> createState() =>
      _LaminateCalculatorScreenState();
}

class _LaminateCalculatorScreenState extends State<LaminateCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomLengthController = TextEditingController();
  final _roomWidthController = TextEditingController();
  final _panelLengthController = TextEditingController();
  final _panelWidthController = TextEditingController();
  final _panelsPerPackController = TextEditingController();
  final _wasteController = TextEditingController(text: '10');

  @override
  void dispose() {
    _roomLengthController.dispose();
    _roomWidthController.dispose();
    _panelLengthController.dispose();
    _panelWidthController.dispose();
    _panelsPerPackController.dispose();
    _wasteController.dispose();
    super.dispose();
  }

  void _reset(LaminateCalculatorProvider provider) {
    _formKey.currentState?.reset();
    _roomLengthController.clear();
    _roomWidthController.clear();
    _panelLengthController.clear();
    _panelWidthController.clear();
    _panelsPerPackController.clear();
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
    bool allowZero = false,
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
      create: (_) => LaminateCalculatorProvider(),
      child: Consumer<LaminateCalculatorProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Калькулятор ламината'),
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
                                controller: _panelLengthController,
                                label: 'Длина панели',
                                suffixText: 'м',
                                onChanged: provider.setPanelLength,
                                validator: (value) =>
                                    _validatePositive(value, 'длину панели'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _panelWidthController,
                                label: 'Ширина панели',
                                suffixText: 'м',
                                onChanged: provider.setPanelWidth,
                                validator: (value) =>
                                    _validatePositive(value, 'ширину панели'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _panelsPerPackController,
                                label: 'Панелей в упаковке',
                                suffixText: 'шт.',
                                onChanged: provider.setPanelsPerPack,
                                validator: (value) => _validateInteger(
                                  value,
                                  'панелей в упаковке',
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
                                label: 'Площадь помещения',
                                value:
                                    '${provider.result!.roomArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Площадь одной панели',
                                value:
                                    '${provider.result!.panelArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Необходимо панелей',
                                value:
                                    '${provider.result!.panelsWithoutWaste} шт.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'С запасом',
                                value:
                                    '${provider.result!.panelsWithWaste} шт.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Упаковок',
                                value: '${provider.result!.packs} шт.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AddToEstimateButton(
                        project: widget.project,
                        itemName: 'Ламинат',
                        quantity: provider.result!.packs.toDouble(),
                        unit: 'уп.',
                        category: 'material',
                        comment:
                            'Ламинат ${provider.result!.packs} упак. с запасом ${provider.result!.wastePercent.toStringAsFixed(0)}%',
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
