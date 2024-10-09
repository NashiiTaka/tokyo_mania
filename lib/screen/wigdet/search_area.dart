import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokyo_mania/screen/lib/attraction.dart';
import 'package:tokyo_mania/screen/lib/tag.dart';
import 'package:tokyo_mania/screen/provider/search_model.dart';
import 'package:tokyo_mania/screen/provider/selected_attraction_model.dart';
import 'package:tokyo_mania/util/supabase_util.dart';

class SearchArea extends StatefulWidget {
  const SearchArea({super.key});

  @override
  _CategorySearchBarState createState() => _CategorySearchBarState();
}

class _CategorySearchBarState extends State<SearchArea> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    // カテゴリの取得
    final categories = await SupabaseUtil.client.from('categories').select();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 検索結果に表示されているアトラクションのタグを取得し、ユニークに。
    List<Tag> uniqueTags = [];
    if (Provider.of<SearchModel>(context).searchedAttractions.isNotEmpty) {
      Provider.of<SearchModel>(context)
          .searchedAttractions
          .forEach((attraction) {
        for (Tag tag in attraction.tags) {
          if (!uniqueTags.contains(tag)) {
            uniqueTags.add(tag);
          }
        }
      });
    }

    // カテゴリのドロップダウンメニューを作成
    final items = _categories.map<DropdownMenuItem<String>>((dynamic value) {
      return DropdownMenuItem<String>(
        value: value['id'].toString(),
        child: Text(
          value['category_name_jp'],
          style: const TextStyle(fontWeight: FontWeight.bold), // ボールドに指定
        ),
      );
    }).toList();

    Attraction? selectedAttraction =
        Provider.of<SelectedAttractionModel>(context).attraction;

    return Column(
      children: [
        Container(
          height: 45,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: selectedAttraction == null
              ? _buildSelectCategoryDropdown(items)
              : _buildDisplayAttraction(selectedAttraction),
        ),
        if (selectedAttraction == null) _buildTagChips(uniqueTags),
      ],
    );
  }

  Widget _buildDisplayAttraction(Attraction attraction) {
    return Row(
      children: [
        Padding(
            padding: EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Provider.of<SelectedAttractionModel>(context, listen: false)
                    .setSelectedAttraction(null);
              },
              child: Icon(Icons.arrow_back_ios_new, color: Colors.grey),
            )),
        Expanded(
          child: Text(attraction.googlePlacesDetailData.displayName.text),
        ),
      ],
    );
  }

  Widget _buildSelectCategoryDropdown(List<DropdownMenuItem<String>> items) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.category, color: Colors.grey),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: Provider.of<SearchModel>(context).categoryID?.toString(),
            hint: const Text('カテゴリを選択'),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (String? newValue) async{
              await Provider.of<SearchModel>(context, listen: false)
                  .setSelectedCategoryID(newValue);
            },
            items: items,
          ),
        ),
      ],
    );
  }

  Widget _buildTagChips(List<Tag> tags) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final tagName = tag.tagNameJP;
          final isSelected =
              Provider.of<SearchModel>(context).tags.contains(tag);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              label: Text(
                tagName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) async{
                if (selected) {
                  await Provider.of<SearchModel>(context, listen: false).addTag(tag);
                } else {
                  await Provider.of<SearchModel>(context, listen: false)
                      .removeTag(tag);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: isSelected ? Colors.blue : Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
