import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../projects/domain/models/project.dart';
import '../providers/paint_calculator_provider.dart';
import '../widgets/add_to_estimate_button.dart';

class PaintCalculatorScreen extends StatefulWidget {
  final Project? project;

  const PaintCalculatorScreen({super.key, this.project});

  @override
  State<PaintCalculatorScreen> createState() => _PaintCalculatorScreenState();
}

class _PaintCalculatorScreenState extends State<PaintCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomLengthController = TextEditingController();
  final _roomWidthController = TextEditingController();
  final _ceilingHeightController = TextEditingController();
  final _doorCountController = TextEditingController(text: '0');
  final _doorWidthController = TextEditingController(text: '0');
  final _doorHeightController = TextEditingController(text: '0');
  final _windowCountController = TextEditingController(text: '0');
  final _windowWidthController = TextEditingController(text: '0');
  final _windowHeightController = TextEditingController(text: '0');
  final _coatsController = TextEditingController(text: '1');
  final _coverageController = TextEditingController();
  final _wasteController = TextEditingController(text: '10');

  @override
  void dispose() {
    _roomLengthController.dispose();
    _roomWidthController.dispose();
    _ceilingHeightController.dispose();
    _doorCountController.dispose();
    _doorWidthController.dispose();
    _doorHeightController.dispose();
    _windowCountController.dispose();
    _windowWidthController.dispose();
    _windowHeightController.dispose();
    _coatsController.dispose();
    _coverageController.dispose();
    _wasteController.dispose();
    super.dispose();
  }

  void _reset(PaintCalculatorProvider provider) {
    _formKey.currentState?.reset();
    _roomLengthController.clear();
    _roomWidthController.clear();
    _ceilingHeightController.clear();
    _doorCountController.text = '0';
    _doorWidthController.text = '0';
    _doorHeightController.text = '0';
    _windowCountController.text = '0';
    _windowWidthController.text = '0';
    _windowHeightController.text = '0';
    _coatsController.text = '1';
    _coverageController.clear();
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
      create: (_) => PaintCalculatorProvider(),
      child: Consumer<PaintCalculatorProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Калькулятор краски'),
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
                              _buildSectionTitle(context, 'Окна и двери'),
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
                                controller: _doorHeightController,
                                label: 'Высота двери',
                                suffixText: 'м',
                                onChanged: provider.setDoorHeight,
                                validator: (value) => _validatePositive(
                                  value,
                                  'высоту двери',
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
                              _buildSectionTitle(context, 'Покрытие'),
                              const SizedBox(height: 16),
                              _buildPaintScopeToggle(provider),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _coatsController,
                                label: 'Количество слоёв',
                                suffixText: 'сл.',
                                onChanged: provider.setCoats,
                                validator: (value) => _validateInteger(
                                  value,
                                  'количество слоёв',
                                  allowZero: false,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _coverageController,
                                label: 'Расход краски',
                                suffixText: 'м²/л',
                                onChanged: provider.setCoverage,
                                validator: (value) =>
                                    _validatePositive(value, 'расход краски'),
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
                              if (provider.result!.ceilingArea > 0) ...[
                                const SizedBox(height: 12),
                                _buildResultRow(
                                  context,
                                  label: 'Площадь потолка',
                                  value:
                                      '${provider.result!.ceilingArea.toStringAsFixed(2)} м²',
                                ),
                              ],
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
                                label: 'Итоговая площадь',
                                value:
                                    '${provider.result!.totalArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Количество слоёв',
                                value: '${provider.result!.coats} сл.',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Расход краски',
                                value:
                                    '${provider.result!.coverage.toStringAsFixed(1)} м²/л',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Требуется краски',
                                value:
                                    '${provider.result!.paintLiters.toStringAsFixed(2)} л',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'С запасом',
                                value:
                                    '${provider.result!.paintLitersRounded.toStringAsFixed(0)} л',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AddToEstimateButton(
                        project: widget.project,
                        itemName: 'Краска',
                        quantity: provider.result!.paintLitersRounded,
                        unit: 'л',
                        category: 'material',
                        comment:
                            'Краска ${provider.result!.paintLitersRounded.toStringAsFixed(0)} л с запасом ${provider.result!.wastePercent.toStringAsFixed(0)}%',
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

  Widget _buildPaintScopeToggle(PaintCalculatorProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Только стены'),
            selected: !provider.includeCeiling,
            onSelected: (selected) {
              provider.setIncludeCeiling(!selected ? true : false);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: const Text('Стены + потолок'),
            selected: provider.includeCeiling,
            onSelected: (selected) {
              provider.setIncludeCeiling(selected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
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
