// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:torn_pda/models/items_model.dart';
import 'package:torn_pda/models/quick_item_model.dart';
import 'package:torn_pda/providers/api/api_v1_calls.dart';
import 'package:torn_pda/utils/shared_prefs.dart';

class QuickItemsProviderFaction extends ChangeNotifier {
  bool _firstLoad = true;
  bool _itemSuccess = false;

  final _activeQuickItemsListFaction = <QuickItem>[];
  UnmodifiableListView<QuickItem> get activeQuickItemsFaction => UnmodifiableListView(_activeQuickItemsListFaction);

  final _fullQuickItemsListFaction = <QuickItem>[];
  UnmodifiableListView<QuickItem> get fullQuickItemsFaction => UnmodifiableListView(_fullQuickItemsListFaction);

  String _currentSearchFilter = '';
  String get searchFilter => _currentSearchFilter;

  final _quickItemTypes = [
    ItemType.ALCOHOL,
    ItemType.BOOSTER,
    ItemType.CANDY,
    ItemType.DRUG,
    ItemType.ENERGY_DRINK,
    ItemType.MEDICAL,
  ];

  final _quickItemExceptions = [
    "box of tissues",
  ];

  Future loadItems() async {
    if (_firstLoad) {
      _firstLoad = false;
      await _loadSaveActiveItems();
      _itemSuccess = await _getAllTornItems();
      notifyListeners();
    } else {
      if (!_itemSuccess) {
        // Trigger with successive calls if the first load was not successful for items
        _itemSuccess = await _getAllTornItems();
      }
      notifyListeners();
    }
  }

  Future _loadSaveActiveItems() async {
    final savedActives = await Prefs().getQuickItemsListFaction();
    bool oldPoints = false;
    for (final rawItem in savedActives) {
      final QuickItem activeItem = quickItemFromJson(rawItem);
      if (activeItem.name == "Faction points refill") {
        oldPoints = true;
        continue;
      }
      _activeQuickItemsListFaction.add(activeItem);
    }
    // v2.8.0 divides points in energy and nerve
    if (oldPoints) {
      _saveListAfterChanges();
    }
  }

  void activateQuickItem(QuickItem newItem) {
    newItem.active = true;
    _activeQuickItemsListFaction.add(newItem);
    _saveListAfterChanges();
    notifyListeners();
  }

  void decreaseInventory(QuickItem item) {
    if (item.inventory! > 0) {
      item.inventory = item.inventory! - 1;
      _saveListAfterChanges();
      notifyListeners();
    }
  }

  void deactivateQuickItem(QuickItem oldItem) {
    oldItem.active = false;
    _activeQuickItemsListFaction.remove(oldItem);
    _saveListAfterChanges();

    // Look for the correct item set active false, so that it reappears in the
    // main available items list
    for (final stock in _fullQuickItemsListFaction) {
      if (stock.name == oldItem.name) {
        stock.active = false;
        break;
      }
    }

    notifyListeners();
  }

  void wipeAllQuickItems() {
    for (final oldItem in _activeQuickItemsListFaction) {
      // Look for the correct item set active false, so that it reappears in the
      // main available items list
      for (final stock in _fullQuickItemsListFaction) {
        if (stock.name == oldItem.name) {
          stock.active = false;
          break;
        }
      }
    }
    _activeQuickItemsListFaction.clear();
    _saveListAfterChanges();
    notifyListeners();
  }

  void setFilterText(String newWordFilter) {
    _currentSearchFilter = newWordFilter;
    notifyListeners();
  }

  void setNumberOfLoadoutsToShow(int number) {
    Prefs().setNumberOfLoadouts(number);
    notifyListeners();
  }

  void _saveListAfterChanges() {
    final saveList = <String>[];

    for (final item in activeQuickItemsFaction) {
      final save = quickItemToJson(item);
      saveList.add(save);
    }

    Prefs().setQuickItemsListFaction(saveList);
  }

  void reorderQuickItem(QuickItem movedItem, int oldIndex, int newIndex) {
    _activeQuickItemsListFaction.removeAt(oldIndex);
    _activeQuickItemsListFaction.insert(newIndex, movedItem);
    _saveListAfterChanges();
    notifyListeners();
  }

  Future _getAllTornItems() async {
    final allTornItems = await ApiCallsV1.getItems();
    if (allTornItems is ItemsModel) {
      // Clears lists in case there are successive calls from the webview
      _fullQuickItemsListFaction.clear();

      // Add Torn items
      allTornItems.items!.forEach((itemNumber, itemProperties) {
        if (_quickItemTypes.contains(itemProperties.type) ||
            _quickItemExceptions.contains(itemProperties.name!.toLowerCase())) {
          // If the item was saved as active, mark it as such so that we can
          // filter it in our full list
          var savedActive = false;
          for (final saved in _activeQuickItemsListFaction) {
            if (saved.name == itemProperties.name) {
              savedActive = true;
              break;
            }
          }

          _fullQuickItemsListFaction.add(
            QuickItem()
              ..name = itemProperties.name
              ..description = itemProperties.description
              ..number = int.parse(itemNumber)
              ..active = savedActive,
          );
        }
      });
      _fullQuickItemsListFaction.sort((a, b) => a.name!.compareTo(b.name!));

      // Insert energy points
      var savedEnergyActive = false;
      const savedNerveActive = false;

      for (final saved in _activeQuickItemsListFaction) {
        if (saved.isEnergyPoints!) {
          savedEnergyActive = true;
        }
        if (saved.isNervePoints!) {
          savedEnergyActive = true;
        }
      }

      _fullQuickItemsListFaction.insert(
        0,
        QuickItem()
          ..name = "Faction energy refill"
          ..description = "Refills energy with faction points"
          ..number = 0
          ..active = savedEnergyActive
          ..isEnergyPoints = true,
      );

      _fullQuickItemsListFaction.insert(
        1,
        QuickItem()
          ..name = "Faction nerve refill"
          ..description = "Refills nerve with faction points"
          ..number = 0
          ..active = savedNerveActive
          ..isNervePoints = true,
      );

      return true;
    }
    return false;
  }
}
