import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';
import '../models/address.dart';

class AddressScreen extends StatefulWidget {
  final Address? selected;

  const AddressScreen({super.key, this.selected});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Address _selected =
      widget.selected ?? kSavedAddresses.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kDarkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Address',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: kDarkText,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          const Text(
            'Choose your location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Let's find your unforgettable event. Choose a location below to get started.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchField(),
          const SizedBox(height: 24),
          const Text(
            'Select location',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 16),
          ...kSavedAddresses.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LocationCard(
                address: a,
                selected: a.label == _selected.label,
                onTap: () => setState(() => _selected = a),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20, color: kDarkText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selected.shortLine,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kDarkText,
              ),
            ),
          ),
          Icon(Icons.my_location, size: 20, color: kPrimary),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;

  const _LocationCard({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? kPrimary : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.region,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            _RadioPin(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioPin extends StatelessWidget {
  final bool selected;

  const _RadioPin({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.white : Colors.grey.shade100,
        border: Border.all(
          color: selected ? kPrimary : Colors.grey.shade200,
          width: selected ? 2 : 1,
        ),
      ),
      child: Icon(
        Icons.location_on,
        size: 18,
        color: selected ? kPrimary : Colors.grey.shade400,
      ),
    );
  }
}
