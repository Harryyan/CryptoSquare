import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:get/get.dart';
import 'package:cryptosquare/l10n/l10n_keywords.dart';

class CountryCodePage extends StatefulWidget {
  const CountryCodePage({Key? key}) : super(key: key);

  @override
  State<CountryCodePage> createState() => _CountryCodePageState();
}

class _CountryCodePageState extends State<CountryCodePage> {
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  // 国家列表
  List<Country> _countryList = [];
  // 过滤后的国家列表
  List<Country> _filteredCountryList = [];
  // 中国作为默认选项
  final Country _chinaCountry = Country(
    phoneCode: '86',
    countryCode: 'CN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: '中国',
    example: '123 456 7890',
    displayName: '中国 (CN)',
    displayNameNoCountryCode: '中国',
    e164Key: '',
  );

  @override
  void initState() {
    super.initState();
    // 初始化国家列表
    _initCountryList();
    // 添加搜索监听
    _searchController.addListener(_filterCountryList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 初始化国家列表
  void _initCountryList() {
    // 获取所有国家
    _countryList = CountryService().getAll();
    // 确保中国不在列表中（因为我们会单独显示）
    _countryList.removeWhere((country) => country.countryCode == 'CN');
    // 初始化过滤列表
    _filteredCountryList = List.from(_countryList);
  }

  // 过滤国家列表
  void _filterCountryList() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredCountryList = List.from(_countryList);
      });
      return;
    }

    setState(() {
      _filteredCountryList =
          _countryList.where((country) {
            return country.name.toLowerCase().contains(query) ||
                country.phoneCode.contains(query) ||
                country.countryCode.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18nKeyword.selectCountryCode.tr),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: I18nKeyword.searchTitle.tr,
                hintText: I18nKeyword.searchHint.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          // 国家列表
          Expanded(
            child: ListView(
              children: [
                // 中国作为默认选项放在最上面
                _buildCountryItem(_chinaCountry),
                const Divider(),
                // 显示所有其他国家
                ..._filteredCountryList
                    .map((country) => _buildCountryItem(country))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryItem(Country country) {
    return ListTile(
      leading: Text(country.flagEmoji, style: const TextStyle(fontSize: 24)),
      title: Text(country.name),
      trailing: Text(
        '+${country.phoneCode}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Get.back(result: country);
      },
    );
  }
}
