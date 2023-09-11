// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:torn_pda/main.dart';
import 'package:torn_pda/models/trades/torntrader/torntrader_auth.dart';
import 'package:torn_pda/models/trades/torntrader/torntrader_in.dart';
import 'package:torn_pda/models/trades/torntrader/torntrader_out.dart';
import 'package:torn_pda/models/trades/trade_item_model.dart';

class TornTraderComm {
  static Future<TornTraderAuthModel> checkIfUserExists(int? user) async {
    var authModel = TornTraderAuthModel();
    try {
      final response =
          await http.post(Uri.parse('https://torntrader.com/api/v1/users?user=$user')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        authModel = tornTraderAuthModelFromJson(response.body);
        authModel.error = false;
      } else {
        authModel.error = true;
      }
    } catch (e) {
      authModel.error = true;
    }
    return authModel;
  }

  static Future<TornTraderInModel> submitItems(List<TradeItem> sellerItems, sellerName, tradeId, buyerId) async {
    var inModel = TornTraderInModel();

    final authModel = await checkIfUserExists(buyerId);
    if (authModel.error!) {
      inModel.serverError = true;
      return inModel;
    }

    if (!authModel.allowed!) {
      inModel.authError = true;
      return inModel;
    }

    final outModel = TornTraderOutModel();
    outModel
      ..appVersion = appVersion
      ..tradeId = tradeId
      ..seller = sellerName
      ..buyer = buyerId
      ..items = <TtOutItem>[];

    for (final product in sellerItems) {
      final item = TtOutItem(
        name: product.name,
        quantity: product.quantity,
        id: product.id,
      );
      outModel.items!.add(item);
    }

    try {
      final response = await http
          .post(
            Uri.parse('https://torntrader.com/api/v1/trades'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': authModel.token!,
            },
            body: tornTraderOutToJson(outModel),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        inModel = tornTraderInModelFromJson(response.body);
      } else {
        inModel.serverError = true;
      }
    } catch (e) {
      inModel.serverError = true;
    }

    return inModel;
  }
}
