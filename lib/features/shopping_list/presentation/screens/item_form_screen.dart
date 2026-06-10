import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/photo_capture/data/photo_repository.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  final ShoppingItem? itemToEdit;

  const ItemFormScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _pricePerKgController = TextEditingController();
  final _substituteNameController = TextEditingController();
  final _substituteQuantityController = TextEditingController(text: '1');
  final _substitutePriceController = TextEditingController();
  late final String _itemId;
  late final String _substituteItemId;

  static const List<String> _defaultTypes = [
    'Padaria',
    'Carnes',
    'Frutas/Verduras',
    'Bebidas',
    'Higiene',
    'Limpeza',
    'Mercearia',
    'Outros',
    'Customizar',
  ];

  String _selectedType = 'Mercearia';
  String _selectedSubstituteType = 'Mercearia';
  bool _isWholesale = false;
  bool _isWeightBased = false;
  bool _hasSubstitute = false;
  String? _photoPath;
  DateTime? _photoCapturedAt;

  @override
  void initState() {
    super.initState();
    _itemId = widget.itemToEdit?.id ?? const Uuid().v4();
    _substituteItemId =
        widget.itemToEdit?.substituteItemId ?? const Uuid().v4();
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _nameController.text = item.productName;
      _photoPath = item.photoUrl;
      _photoCapturedAt = item.photoCapturedAt;

      if (_defaultTypes.contains(item.productType)) {
        _selectedType = item.productType;
      } else {
        _selectedType = 'Customizar';
        _customTypeController.text = item.productType;
      }

      _isWholesale = item.isWholesale;
      _isWeightBased = item.isWeightBased;

      if (_isWeightBased) {
        _weightController.text = item.weightKg?.value.toString() ?? '';
        _pricePerKgController.text = item.pricePerKg != null
            ? (item.pricePerKg!.cents / 100).toStringAsFixed(2)
            : '';
      } else {
        _quantityController.text = item.quantity.value.toString();
        _priceController.text = item.unitPrice != null
            ? (item.unitPrice!.cents / 100).toStringAsFixed(2)
            : '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _pricePerKgController.dispose();
    _substituteNameController.dispose();
    _substituteQuantityController.dispose();
    _substitutePriceController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return false;

    if (_selectedType == 'Customizar' &&
        _customTypeController.text.trim().isEmpty) {
      return false;
    }

    if (_isWeightBased) {
      final weight = double.tryParse(
        _weightController.text.replaceAll(',', '.'),
      );
      if (weight == null || weight <= 0) return false;
      if (!_isOptionalPriceValid(_pricePerKgController.text)) return false;
    } else {
      final qty = double.tryParse(
        _quantityController.text.replaceAll(',', '.'),
      );
      if (qty == null || qty <= 0) return false;
      if (!_isOptionalPriceValid(_priceController.text)) return false;
    }

    if (_hasSubstitute) {
      final substituteName = _substituteNameController.text.trim();
      final substituteQty = double.tryParse(
        _substituteQuantityController.text.replaceAll(',', '.'),
      );
      if (substituteName.isEmpty) return false;
      if (substituteQty == null || substituteQty <= 0) return false;
      if (!_isOptionalPriceValid(_substitutePriceController.text)) {
        return false;
      }
    }

    return true;
  }

  /// Price fields are optional: empty means "price unknown", but if the user
  /// typed something it must be a positive number.
  bool _isOptionalPriceValid(final String text) {
    if (text.trim().isEmpty) return true;
    final value = double.tryParse(text.replaceAll(',', '.'));
    return value != null && value > 0;
  }

  Money? _parseOptionalPrice(final String text) {
    if (text.trim().isEmpty) return null;
    return Money.fromReais(double.parse(text.replaceAll(',', '.')));
  }

  void _onFieldChanged(String _) {
    setState(() {}); // Rebuild to update "Salvar" button state
  }

  Future<void> _capturePhoto() async {
    try {
      final previousPhotoPath = _photoPath;
      final path = await ref
          .read(photoRepositoryProvider)
          .capturePhoto(itemId: _itemId);
      if (!mounted || path.isEmpty) return;

      if (previousPhotoPath != null && previousPhotoPath != path) {
        await ref.read(photoRepositoryProvider).deletePhoto(previousPhotoPath);
      }

      setState(() {
        _photoPath = path;
        _photoCapturedAt = DateTime.now();
      });
    } on PhotoTooLargeException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A foto precisa ter no máximo 5 MB.')),
      );
    }
  }

  Future<void> _removePhoto() async {
    final path = _photoPath;
    if (path != null) {
      await ref.read(photoRepositoryProvider).deletePhoto(path);
    }
    if (!mounted) return;
    setState(() {
      _photoPath = null;
      _photoCapturedAt = null;
    });
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate() || !_isValid()) return;

    final type = _selectedType == 'Customizar'
        ? _customTypeController.text.trim()
        : _selectedType;

    final name = _nameController.text.trim();

    Quantity quantity;
    Money? unitPrice;
    Quantity? weightKg;
    Money? pricePerKg;

    if (_isWeightBased) {
      final weightVal = double.parse(
        _weightController.text.replaceAll(',', '.'),
      );
      weightKg = Quantity(weightVal);
      pricePerKg = _parseOptionalPrice(_pricePerKgController.text);

      // Fallback values for unitPrice and quantity
      quantity = Quantity(weightVal);
      unitPrice = pricePerKg;
    } else {
      final qtyVal = double.parse(
        _quantityController.text.replaceAll(',', '.'),
      );
      quantity = Quantity(qtyVal);
      unitPrice = _parseOptionalPrice(_priceController.text);
    }

    final substituteItem = _hasSubstitute
        ? ShoppingItem(
            id: _substituteItemId,
            productType: _selectedSubstituteType,
            productName: _substituteNameController.text.trim(),
            quantity: Quantity(
              double.parse(
                _substituteQuantityController.text.replaceAll(',', '.'),
              ),
            ),
            unitPrice: _parseOptionalPrice(_substitutePriceController.text),
            createdAt: DateTime.now(),
          )
        : null;

    final newItem = ShoppingItem(
      id: _itemId,
      productType: type,
      productName: name,
      quantity: quantity,
      unitPrice: unitPrice,
      isWholesale: _isWholesale,
      isWeightBased: _isWeightBased,
      weightKg: weightKg,
      pricePerKg: pricePerKg,
      photoUrl: _photoPath,
      photoCapturedAt: _photoCapturedAt,
      substituteItemId: substituteItem?.id,
      createdAt: widget.itemToEdit?.createdAt ?? DateTime.now(),
    );

    if (widget.itemToEdit != null) {
      ref.read(currentListProvider.notifier).updateItem(newItem);
    } else if (substituteItem != null) {
      ref
          .read(currentListProvider.notifier)
          .addItemWithSubstitute(main: newItem, substitute: substituteItem);
    } else {
      ref.read(currentListProvider.notifier).addItem(newItem);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemToEdit == null ? 'Adicionar Item' : 'Editar Item',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                        items: _defaultTypes.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedType = val;
                            });
                          }
                        },
                      ),
                      if (_selectedType == 'Customizar') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Tipo Customizado',
                          ),
                          maxLength: 100,
                          onChanged: _onFieldChanged,
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Produto / Marca',
                        ),
                        maxLength: 200,
                        onChanged: _onFieldChanged,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Atacado'),
                      value: _isWholesale,
                      onChanged: _isWeightBased
                          ? null
                          : (val) {
                              setState(() {
                                _isWholesale = val;
                                if (val) {
                                  final currentQty =
                                      double.tryParse(
                                        _quantityController.text.replaceAll(
                                          ',',
                                          '.',
                                        ),
                                      ) ??
                                      0;
                                  if (currentQty < 3) {
                                    _quantityController.text = '3';
                                  }
                                }
                                _onFieldChanged('');
                              });
                            },
                    ),
                    SwitchListTile(
                      title: const Text('Por peso (KG)'),
                      value: _isWeightBased,
                      onChanged: _isWholesale
                          ? null
                          : (val) {
                              setState(() {
                                _isWeightBased = val;
                                _onFieldChanged('');
                              });
                            },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          if (_isWeightBased) ...[
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                decoration: const InputDecoration(
                                  labelText: 'Peso (kg)',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[\.,]?\d*'),
                                  ),
                                ],
                                onChanged: _onFieldChanged,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _pricePerKgController,
                                decoration: const InputDecoration(
                                  labelText: 'Preço por KG (R\$)',
                                  helperText: 'Opcional',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[\.,]?\d*'),
                                  ),
                                ],
                                onChanged: _onFieldChanged,
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantidade',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[\.,]?\d*'),
                                  ),
                                ],
                                onChanged: _onFieldChanged,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Preço Unitário (R\$)',
                                  helperText: 'Opcional',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[\.,]?\d*'),
                                  ),
                                ],
                                onChanged: _onFieldChanged,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _capturePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          _photoPath == null
                              ? 'Tirar foto da etiqueta'
                              : 'Tirar nova foto',
                        ),
                      ),
                      if (_photoPath != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_photoPath!),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 160,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _removePhoto,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remover foto'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Adicionar substituto'),
                        value: _hasSubstitute,
                        onChanged: (value) {
                          setState(() {
                            _hasSubstitute = value;
                            _onFieldChanged('');
                          });
                        },
                      ),
                      if (_hasSubstitute) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Dados do substituto',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedSubstituteType,
                          decoration: const InputDecoration(
                            labelText: 'Categoria do substituto',
                          ),
                          items: _defaultTypes
                              .where((type) => type != 'Customizar')
                              .map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedSubstituteType = value;
                              _onFieldChanged('');
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _substituteNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do substituto',
                          ),
                          maxLength: 200,
                          onChanged: _onFieldChanged,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _substituteQuantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantidade do substituto',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[\.,]?\d*'),
                                  ),
                                ],
                                onChanged: _onFieldChanged,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _substitutePriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Preço do substituto (R\$)',
                                  helperText: 'Opcional',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[\.,]?\d*'),
                                  ),
                                ],
                                onChanged: _onFieldChanged,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isValid() ? _saveItem : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
