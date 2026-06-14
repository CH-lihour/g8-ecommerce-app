class Address {
  final String label;
  final String city;
  final String country;
  final String details;

  const Address({
    required this.label,
    required this.city,
    required this.country,
    this.details = '',
  });

  String get shortLine => city;

  String get region => '$city, $country';
}

const Address kDefaultAddress = Address(
  label: 'House',
  city: 'San Diego, CA',
  country: 'United States',
  details: '5482 Adobe Falls Rd #15\nSan Diego, California (CA), 92120',
);

const List<Address> kSavedAddresses = [
  Address(
    label: 'House',
    city: 'San Diego, CA',
    country: 'United States',
    details: '5482 Adobe Falls Rd #15\nSan Diego, California (CA), 92120',
  ),
  Address(
    label: 'Los Angeles',
    city: 'Los Angeles',
    country: 'United States',
    details: '1234 Sunset Blvd\nLos Angeles, California (CA), 90026',
  ),
  Address(
    label: 'San Francisco',
    city: 'San Francisco',
    country: 'United States',
    details: '780 Market St\nSan Francisco, California (CA), 94102',
  ),
  Address(
    label: 'New York',
    city: 'New York',
    country: 'United States',
    details: '350 5th Ave\nNew York, NY 10118',
  ),
];
