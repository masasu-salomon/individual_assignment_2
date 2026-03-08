import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';

class AddEditListingScreen extends StatefulWidget {
  const AddEditListingScreen({
    super.key,
    required this.userId,
    this.existingListing,
  });

  final String userId;
  final Listing? existingListing;

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  String _category = ListingCategory.cafe;

  @override
  void initState() {
    super.initState();
    final e = widget.existingListing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _addressController = TextEditingController(text: e?.address ?? '');
    _contactController = TextEditingController(text: e?.contactNumber ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _latController = TextEditingController(
      text: e != null ? e.latitude.toString() : '-1.9536',
    );
    _lngController = TextEditingController(
      text: e != null ? e.longitude.toString() : '30.0606',
    );
    if (e != null) {
      _category = ListingCategory.all.contains(e.category)
          ? e.category
          : ListingCategory.cafe;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid latitude and longitude')),
      );
      return;
    }

    context.read<ListingsProvider>().clearError();
    final listing = Listing(
      id: widget.existingListing?.id ?? '',
      name: _nameController.text.trim(),
      category: _category,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: lat,
      longitude: lng,
      createdBy: widget.userId,
      timestamp: widget.existingListing?.timestamp ?? DateTime.now(),
    );

    final provider = context.read<ListingsProvider>();
    try {
      if (widget.existingListing != null) {
        await provider.updateListing(listing);
      } else {
        await provider.createListing(listing);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingListing != null
                ? 'Listing updated'
                : 'Listing created',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingListing != null;
    final provider = context.watch<ListingsProvider>();
    final isSaving = provider.isSaving;
    final saveError = provider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit listing' : 'Add listing'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Place or service name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ListingCategory.all
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? ListingCategory.cafe),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                  ),
                ],
              ),
              if (saveError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          saveError,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Update listing' : 'Create listing'),
              ),
            ],
          ),
        ),
      ),
          if (isSaving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
