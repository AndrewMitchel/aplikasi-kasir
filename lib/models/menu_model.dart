class MenuModel {
  final int id;
  final String name;
  final int price;
  final int categoryId;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
  });

  factory MenuModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return MenuModel(
      id: map['id'] as int,
      name: map['name'] as String,
      price: map['price'] as int,
      categoryId: map['category_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category_id': categoryId,
    };
  }
}