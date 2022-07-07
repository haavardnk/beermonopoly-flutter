import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store.dart';
import '../helpers/api_helper.dart';
import '../helpers/location_helper.dart';

class Filter with ChangeNotifier {
  String search = '';
  String storeId = '';
  String country = '';
  String style = '';
  String productSelection = '';
  String excludeAllergens = '';
  String priceHigh = '';
  String priceLow = '';
  String ppvHigh = '';
  String ppvLow = '';
  String abvHigh = '';
  String abvLow = '';
  String sortBy = '-rating';
  String release = '';
  int checkIn = 0;
  int wishlisted = 0;

  List<String> selectedStores = [];
  List<Store> storeList = [];

  RangeValues priceRange = const RangeValues(0, 500);
  RangeValues pricePerVolumeRange = const RangeValues(0, 1000);
  RangeValues alcoholRange = const RangeValues(0, 15);

  String sortIndex = 'Global rating - Høy til lav';
  Map<String, String> sortList = {
    'Alkohol - Høy til lav': '-abv',
    'Alkohol - Lav til høy': 'abv',
    'Bryggeri - Stigende': 'brewery',
    'Bryggeri - Synkende': '-brewery',
    'Dato lagt til - Nyeste først': '-created_at',
    'Dato lagt til - Eldste først': 'created_at',
    'Global rating - Høy til lav': '-rating',
    'Global rating - Lav til høy': 'rating',
    'Navn - A til Å': 'vmp_name',
    'Navn - Å til A': '-vmp_name',
    'Pris - Høy til lav': '-price',
    'Pris - Lav til høy': 'price',
    'Pris per liter - Høy til lav': '-price_per_volume',
    'Pris per liter - Lav til høy': 'price_per_volume',
  };
  Map<String, String> sortListAuth = {
    'Alkohol - Høy til lav': '-abv',
    'Alkohol - Lav til høy': 'abv',
    'Bryggeri - Stigende': 'brewery',
    'Bryggeri - Synkende': '-brewery',
    'Dato lagt til - Nyeste først': '-created_at',
    'Dato lagt til - Eldste først': 'created_at',
    'Din rating - Høy til lav': '-checkin__rating',
    'Din rating - Lav til høy': 'checkin__rating',
    'Global rating - Høy til lav': '-rating',
    'Global rating - Lav til høy': 'rating',
    'Navn - A til Å': 'vmp_name',
    'Navn - Å til A': '-vmp_name',
    'Pris - Høy til lav': '-price',
    'Pris - Lav til høy': 'price',
    'Pris per liter - Høy til lav': '-price_per_volume',
    'Pris per liter - Lav til høy': 'price_per_volume',
  };

  List<bool> styleSelectedList = List<bool>.filled(23, false);
  List<Map<String, String>> styleList = [
    {
      'Annet': 'adambier,altbier,brett,burton,tan,chilli,cream ale,festbier,grape ale,'
          'happoshu,historical,honey beer,kellerbier,koji,kvass,lichtenhainer,'
          'malt beer,mild,pumpkin,rauchbier,roggenbier,root beer,rye beer,schwarzbier,'
          'smoked beer,shandy,scotch ale,scottish,steinbier,spiced / herbed,strong ale,table beer,zoigl'
    },
    {'Barleywine': 'barleywine'},
    {'Belgisk': 'belgian'},
    {'Blonde': 'blonde'},
    {'Bokk': 'bock'},
    {'Brown Ale': 'brown'},
    {'Dark Ale': 'dark ale'},
    {'Farmhouse Ale': 'farmhouse ale'},
    {'Glutenfri': 'gluten-free'},
    {'Hvete': 'wheat beer'},
    {'IPA': 'ipa'},
    {'Juleøl': 'winter'},
    {'Kölsch': 'kölsch'},
    {'Lager': 'lager'},
    {'Mjød': 'mead'},
    {'Old Ale': 'old ale, traditional ale'},
    {'Pale Ale': 'pale ale'},
    {'Pilsner': 'pilsner'},
    {'Porter': 'porter'},
    {'Red Ale': 'red ale -'},
    {'Sider': 'cider'},
    {'Stout': 'stout'},
    {'Surøl': 'sour,wild ale,lambic,fruit beer'},
  ];

  List<String> selectedCountries = [];
  List<String> countryList = [
    'Argentina',
    'Australia',
    'Belgia',
    'Canada',
    'Danmark',
    'EU',
    'England',
    'Estland',
    'Frankrike',
    'Færøyene',
    'Hellas',
    'India',
    'Irland',
    'Island',
    'Italia',
    'Japan',
    'Kina',
    'Kroatia',
    'Latvia',
    'Litauen',
    'Mexico',
    'Nederland',
    'New Zealand',
    'Norge',
    'Palestina',
    'Peru',
    'Polen',
    'Portugal',
    'Russland',
    'Serbia',
    'Singapore',
    'Skottland',
    'Spania',
    'Storbritannia',
    'Sveits',
    'Sverige',
    'Sør-Afrika',
    'Thailand',
    'Tsjekkia',
    'Tyrkia',
    'Tyskland',
    'USA',
    'Ungarn',
    'Ukraina',
    'Wales',
    'Østerrike'
  ];

  List<bool> productSelectionSelectedList = List<bool>.filled(5, false);
  List<Map<String, String>> productSelectionList = [
    {'Basisutvalget': 'basisutvalget'},
    {'Bestillingsutvalget': 'bestillingsutvalget'},
    {'Partiutvalget': 'partiutvalget'},
    {'Spesialutvalget': 'spesialutvalg'},
    {'Tilleggsutvalget': 'tilleggsutvalget'},
  ];

  List<bool> excludeAllergensSelectedList = List<bool>.filled(4, false);
  List<Map<String, String>> excludeAllergensList = [
    {'Gluten': 'gluten, bygg, spelt, hvete, havre, rug'},
    {'Laktose': 'laktose, melk'},
    {'Nøtter': 'nøtter, peanøtt, hasselnøtt, valnøtt, nøtt'},
    {'Sulfitt': 'sulfitt'},
  ];

  List<bool> deliverySelectedList = List<bool>.filled(2, false);
  List<String> deliveryList = ['Levering til butikk', 'Levering på posten'];

  List<bool> releaseSelectedList = [];
  List<String> releaseList = [];

  List<String> checkinList = [
    'Alle',
    'Innsjekket',
    'Ikke innsjekket',
  ];

  List<String> wishlistList = [
    'Alle',
    'I ønskeliste',
    'Ikke i ønskeliste',
  ];

  List<Map<String, dynamic>> filterSaveSettings = [
    {'name': 'store', 'text': 'Butikklager', 'save': true},
    {'name': 'price', 'text': 'Pris', 'save': false},
    {'name': 'pricePerVolume', 'text': 'Pris per liter', 'save': false},
    {'name': 'sortBy', 'text': 'Sortering', 'save': false},
    {'name': 'style', 'text': 'Stil', 'save': false},
    {'name': 'country', 'text': 'Land', 'save': false},
    {'name': 'alcohol', 'text': 'Alkohol', 'save': false},
    {'name': 'productSelection', 'text': 'Produktutvalg', 'save': false},
    {'name': 'excludeAllergens', 'text': 'Allergener', 'save': false},
    {'name': 'delivery', 'text': 'Bestilling', 'save': false},
    {'name': 'checkIn', 'text': 'Untappd Innsjekket', 'save': false},
    {'name': 'wishlisted', 'text': 'Untappd Ønskeliste', 'save': false},
  ];

  Filter get filters {
    return this;
  }

  bool storesLoading = false;
  Future<List<Store>> getStores() async {
    if (storeList.isNotEmpty && storeList.length > 1 && !storesLoading) {
      return storeList;
    }
    try {
      storesLoading = true;
      var stores = await ApiHelper.getStoreList();
      storeList = stores;
      storeList = await LocationHelper.calculateStoreDistance(storeList);
      storeList.sort((a, b) => a.distance!.compareTo(b.distance!));
      storesLoading = false;
      notifyListeners();
      return storeList;
    } catch (error) {
      storesLoading = false;
      notifyListeners();
      return storeList;
    }
  }

  bool releasesLoading = false;
  Future<List<String>> getReleases() async {
    if (releaseList.isNotEmpty && releaseList.length > 1 && !releasesLoading) {
      return releaseList;
    }
    try {
      releasesLoading = true;
      var releases = await ApiHelper.getReleaseList();
      releaseList = releases;
      releaseSelectedList = List<bool>.filled(releaseList.length, false);
      releasesLoading = false;
      notifyListeners();
      return releaseList;
    } catch (error) {
      releasesLoading = false;
      notifyListeners();
      return releaseList;
    }
  }

  void setPriceRange(RangeValues range) {
    priceRange = range;
    if (priceRange.end == 500) {
      priceHigh = '';
      priceLow = priceRange.start.toString();
    } else {
      priceHigh = priceRange.end.toString();
      priceLow = priceRange.start.toString();
    }
    notifyListeners();
    saveFilters();
  }

  void setPricePerVolumeRange(RangeValues range) {
    pricePerVolumeRange = range;
    if (pricePerVolumeRange.end == 500) {
      ppvHigh = '';
      ppvLow = pricePerVolumeRange.start.toString();
    } else {
      ppvHigh = pricePerVolumeRange.end.toString();
      ppvLow = pricePerVolumeRange.start.toString();
    }
    notifyListeners();
    saveFilters();
  }

  void setAlcoholRange(RangeValues range) {
    alcoholRange = range;
    if (alcoholRange.end == 500) {
      abvHigh = '';
      abvLow = alcoholRange.start.toString();
    } else {
      abvHigh = alcoholRange.end.toString();
      abvLow = alcoholRange.start.toString();
    }
    notifyListeners();
    saveFilters();
  }

  void setSortBy(String index) {
    sortIndex = index;
    sortBy = sortListAuth[index]!;
    notifyListeners();
    saveFilters();
  }

  void setStyle(int index, bool boolean) {
    styleSelectedList[index] = boolean;
    var temporaryStyle = '';
    styleSelectedList.asMap().forEach(
      (index, value) {
        if (value) {
          if (temporaryStyle.isNotEmpty) {
            temporaryStyle += ',';
          }
          temporaryStyle += styleList[index].values.first;
        }
      },
    );
    style = temporaryStyle;
    notifyListeners();
    saveFilters();
  }

  void setProductSelection(int index, bool boolean) {
    productSelectionSelectedList[index] = boolean;
    var temporaryProductSelection = '';
    productSelectionSelectedList.asMap().forEach(
      (index, value) {
        if (value) {
          if (temporaryProductSelection.isNotEmpty) {
            temporaryProductSelection += ',';
          }
          temporaryProductSelection += productSelectionList[index].values.first;
        }
      },
    );
    productSelection = temporaryProductSelection;
    notifyListeners();
    saveFilters();
  }

  void setExcludeAllergensSelection(int index, bool boolean) {
    excludeAllergensSelectedList[index] = boolean;
    var temporaryProductSelection = '';
    excludeAllergensSelectedList.asMap().forEach(
      (index, value) {
        if (value) {
          if (temporaryProductSelection.isNotEmpty) {
            temporaryProductSelection += ',';
          }
          temporaryProductSelection += excludeAllergensList[index].values.first;
        }
      },
    );
    excludeAllergens = temporaryProductSelection;
    notifyListeners();
    saveFilters();
  }

  void setDeliverySelection(int index, bool boolean) {
    deliverySelectedList[index] = boolean;
    notifyListeners();
    saveFilters();
  }

  void setRelease(int index, bool boolean) {
    releaseSelectedList[index] = boolean;
    var temporaryRelease = '';
    releaseSelectedList.asMap().forEach(
      (index, value) {
        if (value) {
          if (temporaryRelease.isNotEmpty) {
            temporaryRelease += ',';
          }
          temporaryRelease += releaseList[index];
        }
      },
    );
    release = temporaryRelease;
    notifyListeners();
  }

  void setCheckin(int index) {
    checkIn = index;
    notifyListeners();
    saveFilters();
  }

  void setWishlisted(int index) {
    wishlisted = index;
    notifyListeners();
    saveFilters();
  }

  void setSearch(String text) {
    search = text;
    notifyListeners();
  }

  void setCountry() {
    if (selectedCountries.isEmpty) {
      country = '';
    } else {
      String temporaryCountries = '';
      selectedCountries.forEach((countryName) {
        if (temporaryCountries.isNotEmpty) {
          temporaryCountries += ',';
        }
        temporaryCountries += countryName;
      });
      country = temporaryCountries;
    }
    notifyListeners();
    saveFilters();
  }

  void setStore() {
    if (selectedStores.isEmpty) {
      storeId = '';
    } else {
      String temporaryStores = '';
      selectedStores.forEach((storeName) {
        if (temporaryStores.isNotEmpty) {
          temporaryStores += ',';
        }
        temporaryStores +=
            storeList.firstWhere((element) => element.name == storeName).id;
      });
      storeId = temporaryStores;
    }
    notifyListeners();
    saveFilters();
  }

  void resetFilters() {
    styleSelectedList = List<bool>.filled(23, false);
    productSelectionSelectedList = List<bool>.filled(5, false);
    excludeAllergensSelectedList = List<bool>.filled(4, false);
    deliverySelectedList = List<bool>.filled(2, false);
    releaseSelectedList = List<bool>.filled(releaseList.length, false);
    priceRange = const RangeValues(0, 500);
    pricePerVolumeRange = const RangeValues(0, 1000);
    alcoholRange = const RangeValues(0, 15);
    sortIndex = 'Global rating - Høy til lav';
    storeId = '';
    selectedStores = [];
    country = '';
    selectedCountries = [];
    style = '';
    productSelection = '';
    excludeAllergens = '';
    priceHigh = '';
    priceLow = '';
    ppvHigh = '';
    ppvLow = '';
    abvHigh = '';
    abvLow = '';
    sortBy = '-rating';
    release = '';
    checkIn = 0;
    wishlisted = 0;
    notifyListeners();
    saveFilters();
  }

  void setFilters() {
    notifyListeners();
  }

  void saveFilterSettings() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    filterSaveSettings.forEach((filter) {
      prefs.setBool(filter['name'] + 'Last', filter['save']);
    });
  }

  Future<void> loadFilterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    filterSaveSettings.forEach((filter) {
      filter['save'] = prefs.getBool(filter['name'] + 'Last') ?? filter['save'];
    });
  }

  void saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    filterSaveSettings.forEach((filter) {
      if (filter['name'] == 'store' && filter['save'] == true) {
        prefs.setString('storeId', storeId);
        prefs.setStringList('selectedStores', selectedStores);
      }
      if (filter['name'] == 'price' && filter['save'] == true) {
        prefs.setString('priceHigh', priceHigh);
        prefs.setString('priceLow', priceLow);
      }
      if (filter['name'] == 'pricePerVolume' && filter['save'] == true) {
        prefs.setString('ppvHigh', ppvHigh);
        prefs.setString('ppvLow', ppvLow);
      }
      if (filter['name'] == 'sortBy' && filter['save'] == true) {
        prefs.setString('sortBy', sortBy);
        prefs.setString('sortIndex', sortIndex);
      }
      if (filter['name'] == 'style' && filter['save'] == true) {
        prefs.setString('style', style);
        prefs.setStringList(
            'styleSelectedList',
            styleSelectedList
                .map((e) => e == true ? 'true' : 'false')
                .toList());
      }
      if (filter['name'] == 'country' && filter['save'] == true) {
        prefs.setString('country', country);
        prefs.setStringList('selectedCountries', selectedCountries);
      }
      if (filter['name'] == 'alcohol' && filter['save'] == true) {
        prefs.setString('abvHigh', abvHigh);
        prefs.setString('abvLow', abvLow);
      }
      if (filter['name'] == 'productSelection' && filter['save'] == true) {
        prefs.setString('productSelection', productSelection);
        prefs.setStringList(
            'productSelectionSelectedList',
            productSelectionSelectedList
                .map((e) => e == true ? 'true' : 'false')
                .toList());
      }
      if (filter['name'] == 'excludeAllergens' && filter['save'] == true) {
        prefs.setString('excludeAllergens', excludeAllergens);
        prefs.setStringList(
            'excludeAllergensSelectedList',
            excludeAllergensSelectedList
                .map((e) => e == true ? 'true' : 'false')
                .toList());
      }
      if (filter['name'] == 'delivery' && filter['save'] == true) {
        prefs.setStringList(
            'deliverySelectedList',
            deliverySelectedList
                .map((e) => e == true ? 'true' : 'false')
                .toList());
      }
      if (filter['name'] == 'checkIn' && filter['save'] == true) {
        prefs.setInt('checkIn', checkIn);
      }
      if (filter['name'] == 'wishlisted' && filter['save'] == true) {
        prefs.setInt('wishlisted', wishlisted);
      }
    });
  }

  Future<void> loadFilters() async {
    await loadFilterSettings();
    final prefs = await SharedPreferences.getInstance();
    filterSaveSettings.forEach((filter) {
      if (filter['name'] == 'store' && filter['save'] == true) {
        storeId = prefs.getString('storeId') ?? '';
        selectedStores = prefs.getStringList('selectedStores') ?? [];
      }
      if (filter['name'] == 'price' && filter['save'] == true) {
        priceHigh = prefs.getString('priceHigh') ?? '';
        priceLow = prefs.getString('priceLow') ?? '';
        priceRange = RangeValues(
            priceLow.isNotEmpty ? double.parse(priceLow) : priceRange.start,
            priceHigh.isNotEmpty ? double.parse(priceHigh) : priceRange.end);
      }
      if (filter['name'] == 'pricePerVolume' && filter['save'] == true) {
        ppvHigh = prefs.getString('ppvHigh') ?? '';
        ppvLow = prefs.getString('ppvLow') ?? '';
        pricePerVolumeRange = RangeValues(
            ppvLow.isNotEmpty
                ? double.parse(ppvLow)
                : pricePerVolumeRange.start,
            ppvHigh.isNotEmpty
                ? double.parse(ppvHigh)
                : pricePerVolumeRange.end);
      }
      if (filter['name'] == 'sortBy' && filter['save'] == true) {
        sortBy = prefs.getString('sortBy') ?? '-rating';
        sortIndex =
            prefs.getString('sortIndex') ?? 'Global rating - Høy til lav';
      }
      if (filter['name'] == 'style' && filter['save'] == true) {
        style = prefs.getString('style') ?? '';
        var tempList = prefs.getStringList('styleSelectedList');
        styleSelectedList = tempList != null
            ? tempList.map((e) => e == "true").toList()
            : List<bool>.filled(23, false);
      }
      if (filter['name'] == 'country' && filter['save'] == true) {
        country = prefs.getString('country') ?? '';
        selectedCountries = prefs.getStringList('selectedCountries') ?? [];
      }
      if (filter['name'] == 'alcohol' && filter['save'] == true) {
        abvHigh = prefs.getString('abvHigh') ?? '';
        abvLow = prefs.getString('abvLow') ?? '';
        alcoholRange = RangeValues(
            abvLow.isNotEmpty ? double.parse(abvLow) : alcoholRange.start,
            abvHigh.isNotEmpty ? double.parse(abvHigh) : alcoholRange.end);
      }
      if (filter['name'] == 'productSelection' && filter['save'] == true) {
        productSelection = prefs.getString('productSelection') ?? '';
        var tempList = prefs.getStringList('productSelectionSelectedList');
        productSelectionSelectedList = tempList != null
            ? tempList.map((e) => e == "true").toList()
            : List<bool>.filled(5, false);
      }
      if (filter['name'] == 'excludeAllergens' && filter['save'] == true) {
        excludeAllergens = prefs.getString('excludeAllergens') ?? '';
        var tempList = prefs.getStringList('excludeAllergensSelectedList');
        excludeAllergensSelectedList = tempList != null
            ? tempList.map((e) => e == "true").toList()
            : List<bool>.filled(5, false);
      }
      if (filter['name'] == 'delivery' && filter['save'] == true) {
        var tempList = prefs.getStringList('deliverySelectedList');
        deliverySelectedList = tempList != null
            ? tempList.map((e) => e == "true").toList()
            : List<bool>.filled(2, false);
      }
      if (filter['name'] == 'delivery' && filter['save'] == true) {
        checkIn = prefs.getInt('checkIn') ?? 0;
      }
      if (filter['name'] == 'wishlisted' && filter['save'] == true) {
        wishlisted = prefs.getInt('wishlisted') ?? 0;
      }
    });
    notifyListeners();
  }
}
