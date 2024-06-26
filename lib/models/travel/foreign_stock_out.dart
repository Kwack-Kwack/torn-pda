// To parse this JSON data, do
//
//     final foreignStockOutModel = foreignStockOutModelFromJson(jsonString);

import 'dart:convert';

ForeignStockOutModel foreignStockOutModelFromJson(String str) => ForeignStockOutModel.fromJson(json.decode(str));

String foreignStockOutModelToJson(ForeignStockOutModel data) => json.encode(data.toJson());

class ForeignStockOutModel {
  String client;
  String version;
  String authorName;
  int authorId;
  String country;
  List<ForeignStockOutItem> items;

  ForeignStockOutModel({
    required this.client,
    required this.version,
    required this.authorName,
    required this.authorId,
    required this.country,
    required this.items,
  });

  factory ForeignStockOutModel.fromJson(Map<String, dynamic> json) => ForeignStockOutModel(
        client: json["client"],
        version: json["version"],
        authorName: json["author_name"],
        authorId: json["author_id"],
        country: json["country"],
        items: List<ForeignStockOutItem>.from(json["items"].map((x) => ForeignStockOutItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "client": client,
        "version": version,
        "author_name": authorName,
        "author_id": authorId,
        "country": country,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class ForeignStockOutItem {
  int id;
  int quantity;
  int cost;

  ForeignStockOutItem({
    required this.id,
    required this.quantity,
    required this.cost,
  });

  factory ForeignStockOutItem.fromJson(Map<String, dynamic> json) => ForeignStockOutItem(
        id: json["id"],
        quantity: json["quantity"],
        cost: json["cost"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quantity": quantity,
        "cost": cost,
      };
}
