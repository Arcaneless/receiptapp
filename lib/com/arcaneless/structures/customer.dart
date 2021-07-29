// Customer

class Customer {
  String name;
  String telno;
  String email;
  String address;

  Customer({this.name, this.telno, this.email, this.address});

  Map toJson() => {
    'name': name,
    'telno': telno,
    'email': email,
    'address': address
  };

  factory Customer.fromJson(dynamic json) {
    return Customer(
        name : json['name'] as String,
        telno : json['telno'] as String,
        email : json['email'] as String,
        address : json['address'] as String,
    );
  }
}