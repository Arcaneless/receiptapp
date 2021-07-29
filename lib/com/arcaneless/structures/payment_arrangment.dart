final List<Map<String, dynamic>> defaults = [
  {
    'percentageSplit': 40,
    'whenToPay': '簽約時'
  },
  {
    'percentageSplit': 30,
    'whenToPay': '水電完成時'
  },
  {
    'percentageSplit': 20,
    'whenToPay': '泥水完成時'
  },
  {
    'percentageSplit': 10,
    'whenToPay': '完工時'
  },
];

class PaymentArrangement {
  int percentageSplit;
  String whenToPay;

  PaymentArrangement({this.percentageSplit = 0, this.whenToPay = ''});

  Map<String, dynamic> toJson() {
    return {
      'percentageSplit': percentageSplit,
      'whenToPay': whenToPay
    };
  }

  factory PaymentArrangement.fromDefaultIndex(int defaultIndex) {
    return PaymentArrangement(
        percentageSplit: defaults[defaultIndex]['percentageSplit'],
        whenToPay: defaults[defaultIndex]['whenToPay']
    );
  }

  factory PaymentArrangement.fromJson(dynamic json, int defaultIndex) {
    return PaymentArrangement(
      percentageSplit: json['percentageSplit'] ?? defaults[defaultIndex]['percentageSplit'],
      whenToPay: json['whenToPay'] ?? defaults[defaultIndex]['whenToPay']
    );
  }
}