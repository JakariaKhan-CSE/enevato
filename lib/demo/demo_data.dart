class DemoData {
  static const Map<String, dynamic> account = {
    'username': 'Demo',
    'firstname': 'Demo',
    'surname': 'Account',
    'available_earnings': '555.24',
    'total_deposits': '1200.00',
    'balance': '555.24',
    'country': 'Bangladesh',
  };

  static const Map<String, dynamic> userDetails = {
    'username': 'Demo',
    'country': 'Bangladesh',
    'location': 'Dhaka, Bangladesh',
    'sales': '925',
    'followers': '616',
    'image': '',
  };

  static const List<Map<String, dynamic>> earningsByMonth = [
    {
      'month': 'Thu Dec 01 00:00:00 +1100 2022',
      'sales': 4,
      'earnings': 15.75,
    },
    {
      'month': 'Sun Jan 01 00:00:00 +1100 2023',
      'sales': 20,
      'earnings': 158.07,
    },
    {
      'month': 'Wed Feb 01 00:00:00 +1100 2023',
      'sales': 4,
      'earnings': 28.74,
    },
    {
      'month': 'Wed Mar 01 00:00:00 +1100 2023',
      'sales': 4,
      'earnings': 81.87,
    },
    {
      'month': 'Sat Apr 01 00:00:00 +1100 2023',
      'sales': 1,
      'earnings': 25.00,
    },
    {
      'month': 'Mon May 01 00:00:00 +1000 2023',
      'sales': 2,
      'earnings': 33.75,
    },
  ];

  static const List<Map<String, dynamic>> statementLines = [
    {
      'type': 'Sale',
      'detail': 'Item 24',
      'amount': 154.53,
      'date': '2026-01-23T18:31:00Z',
      'site': 'CodeCanyon',
      'other_party_country': 'Bangladesh',
    },
    {
      'type': 'Sale',
      'detail': 'Item 12',
      'amount': 100.75,
      'date': '2026-01-22T17:11:00Z',
      'site': 'CodeCanyon',
      'other_party_country': 'United States',
    },
    {
      'type': 'Sale',
      'detail': 'Item 18',
      'amount': 90.62,
      'date': '2026-01-20T10:18:00Z',
      'site': 'CodeCanyon',
      'other_party_country': 'Singapore',
    },
    {
      'type': 'Sale',
      'detail': 'Item 07',
      'amount': 71.55,
      'date': '2026-01-18T08:10:00Z',
      'site': 'ThemeForest',
      'other_party_country': 'Brazil',
    },
    {
      'type': 'Sale Reversal',
      'detail': 'Refund',
      'amount': -15.25,
      'date': '2026-01-17T06:12:00Z',
      'site': 'CodeCanyon',
      'other_party_country': 'United Kingdom',
    },
  ];

  static const List<Map<String, dynamic>> portfolioSites = [
    {'site': 'CodeCanyon', 'items': '10'},
  ];

  static const Map<String, List<Map<String, dynamic>>> portfolioItemsBySite = {
    'codecanyon': [
      {
        'item': 'Kids Battle Flutter android and ios application',
        'thumbnail':
            'https://previews.customer.envatousercontent.com/files/651301320/thubnail.png',
        'sales': '1',
        'rating': '0.0',
        'cost': '19.00',
      },
      {
        'item': 'Focus DoM: Deep Work Timer Flutter Productivity App',
        'thumbnail':
            'https://previews.customer.envatousercontent.com/files/640952148/thubnail.png',
        'sales': '2',
        'rating': '0.0',
        'cost': '49.00',
      },
      {
        'item':
            'Focus Flash – Productivity & Pomodoro App & Google Admob Ads',
        'thumbnail':
            'https://previews.customer.envatousercontent.com/files/637491375/thubnail.png',
        'sales': '1',
        'rating': '0.0',
        'cost': '24.00',
      },
    ],
  };

  static const List<Map<String, dynamic>> badges = [
    {
      'label': '6 Years of Membership',
      'image':
          'https://public-assets.envato-static.com/assets/badges/veteran_level_6-1d32ecdbdf08c40fbdb636697bbbaa0732d6dd200b8082d6e39c13fc3e61ac1a.svg',
    },
    {
      'label': 'Author Level 3',
      'image':
          'https://public-assets.envato-static.com/assets/badges/author_level_3-21e0f52cfefd842a5ee111e54ec097cec50c9adcef9fad6452c7fb0f8f7d99f4.svg',
    },
    {
      'label': 'Bangladesh',
      'image':
          'https://public-assets.envato-static.com/assets/badges/country_bd-4c5a009b61228bb4918098f9b1ccb4d7282cf53bc578d1b35c46b5c14f144a98.svg',
    },
  ];
}
