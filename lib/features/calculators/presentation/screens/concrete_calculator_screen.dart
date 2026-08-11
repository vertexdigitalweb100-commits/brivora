import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/concrete_calculator_provider.dart';

class ConcreteCalculatorScreen extends StatefulWidget {
  const ConcreteCalculatorScreen({super.key});

  @override
  State<ConcreteCalculatorScreen> createState() => _ConcreteCalculatorScreenState();
}

class _ConcreteCalculatorScreenState extends State<ConcreteCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _thicknessController = TextEditingController();
  final _wasteController = TextEditingController(text: '10');

  static const List<String> _constructionTypes = [
    'Пол',
    'Фундамент',
    'Площадка',
    'Другое',
  ];

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _thicknessController.dispose();
    _wasteController.dispose();
    super.dispose();
  }

  void _reset(ConcreteCalculatorProvider provider) {
    _formKey.currentState?.reset();
    _lengthController.clear();
    _widthController.clear();
    _thicknessController.clear();
    _wasteController.text = '10';
    provider.reset();
  }

  String? _validatePositive(String? value, String label, {bool allowZero = false}) {
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConcreteCalculatorProvider(),
      child: Consumer<ConcreteCalculatorProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Калькулятор бетона'),
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
                                controller: _lengthController,
                                label: 'Длина',
                                suffixText: 'м',
                                onChanged: provider.setLength,
                                validator: (value) => _validatePositive(value, 'длину'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _widthController,
                                label: 'Ширина',
                                suffixText: 'м',
                                onChanged: provider.setWidth,
                                validator: (value) => _validatePositive(value, 'ширину'),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _thicknessController,
                                label: 'Толщина',
                                suffixText: 'см',
                                onChanged: provider.setThickness,
                                validator: (value) => _validatePositive(value, 'толщину'),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Тип конструкции',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _constructionTypes.map((type) {
                                  return ChoiceChip(
                                    label: Text(type),
                                    selected: provider.constructionType == type,
                                    onSelected: (_) => provider.setConstructionType(type),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              _buildNumberField(
                                controller: _wasteController,
                                label: 'Запас бетона',
                                suffixText: '%',
                                onChanged: provider.setWastePercent,
                                validator: (value) => _validatePositive(
                                  value,
                                  'запас бетона',
                                  allowZero: true,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState?.validate() ?? false) {
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
                                label: 'Площадь поверхности',
                                value: '${provider.result!.surfaceArea.toStringAsFixed(2)} м²',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Объём без запаса',
                                value: '${provider.result!.volumeWithoutWaste.toStringAsFixed(2)} м³',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Объём с запасом',
                                value: '${provider.result!.volumeWithWaste.toStringAsFixed(2)} м³',
                              ),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                context,
                                label: 'Необходимо бетона',
                                value: '${provider.result!.volumeLiters.toStringAsFixed(0)} л',
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
