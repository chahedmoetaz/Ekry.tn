
class PopularFilterListData {
  PopularFilterListData({
    this.titleTxt = '',
    this.isSelected = false,
  });

  String titleTxt;
  bool isSelected;

  static List<PopularFilterListData> popularFList = <PopularFilterListData>[
    PopularFilterListData(
      titleTxt:"clim",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: "Parking",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'wifi',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'anc',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'pis',
      isSelected: false,
    ),
  ];
  static List<PopularFilterListData> popularList = <PopularFilterListData>[
    PopularFilterListData(
      titleTxt:"clim",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"chauf",
      isSelected: false,
    ),

    PopularFilterListData(
      titleTxt: "Parking",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'wifi',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'anc',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'pis',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'cuisine',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"lavel",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"ech",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"slange",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"ferr",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"jacc",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"bureau",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"chaise",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"table",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"ascen",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"chem",
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt:"friends",
      isSelected: false,
    ),
  ];

  static List<PopularFilterListData> accomodationList = [
    PopularFilterListData(
      titleTxt: 'tous',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Appartement',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Maison',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Villa',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'studio',
      isSelected: false,
    ),

    PopularFilterListData(
      titleTxt: 'bungalow',
      isSelected: false,
    ),
  ];
}
