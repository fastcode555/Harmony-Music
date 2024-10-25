import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/screens/Search/components/search_item.dart';
import 'package:harmonymusic/ui/screens/Search/search_screen_controller.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/modified_text_field.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchScreenController = Get.put(SearchScreenController());
    final settingsScreenController = Get.find<SettingsScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 80.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(
        () => row.children([
          if (settingsScreenController.isBottomNavBarEnabled.isFalse)
            container.w110.color(Theme.of(context).navigationRailTheme.backgroundColor).child(
                  column.children([
                    Padding(
                      padding: EdgeInsets.only(top: topPadding),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Theme.of(context).textTheme.titleMedium!.color,
                        ),
                        onPressed: () {
                          Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                        },
                      ),
                    ),
                  ]),
                )
          else
            const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: topPadding, left: 5),
              child: column.children([
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'search'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 10),
                ModifiedTextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: searchScreenController.textInputController,
                  textInputAction: TextInputAction.search,
                  onChanged: searchScreenController.onChanged,
                  onSubmitted: (val) {
                    if (val.contains('https://')) {
                      searchScreenController.filterLinks(Uri.parse(val));
                      searchScreenController.reset();
                      return;
                    }
                    Get.toNamed(
                      ScreenNavigationSetup.searchResultScreen,
                      id: ScreenNavigationSetup.id,
                      arguments: val,
                    );
                    searchScreenController.addToHistoryQueryList(val);
                  },
                  autofocus: settingsScreenController.isBottomNavBarEnabled.isFalse,
                  cursorColor: Theme.of(context).textTheme.bodySmall!.color,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 5),
                      focusColor: Colors.white,
                      hintText: 'searchDes'.tr,
                      suffix: IconButton(
                        onPressed: searchScreenController.reset,
                        icon: Icons.close.icon.mk,
                        splashRadius: 16,
                        iconSize: 19,
                      )),
                ),
                Expanded(
                  child: Obx(() {
                    final isEmpty = searchScreenController.suggestionList.isEmpty ||
                        searchScreenController.textInputController.text == '';
                    final list = isEmpty
                        ? searchScreenController.historyQuerylist.toList()
                        : searchScreenController.suggestionList.toList();
                    return ListView(
                      padding: const EdgeInsets.only(top: 5, bottom: 400),
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      children: searchScreenController.urlPasted.isTrue
                          ? [
                              InkWell(
                                onTap: () {
                                  searchScreenController
                                      .filterLinks(Uri.parse(searchScreenController.textInputController.text));
                                  searchScreenController.reset();
                                },
                                child: padding.pv20.child(
                                  SizedBox(
                                    width: double.maxFinite,
                                    height: 60,
                                    child: Center(
                                        child: Text(
                                      'urlSearchDes'.tr,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    )),
                                  ),
                                ),
                              )
                            ]
                          : list.map((item) => SearchItem(queryString: item, isHistoryString: isEmpty)).toList(),
                    );
                  }),
                )
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
