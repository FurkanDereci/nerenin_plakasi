import 'package:flutter/material.dart';
import '../models/city_plate.dart';
import '../services/search_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  List<CityPlate> _results = [];
  bool _searchByCity = true; // true = şehre göre, false = plakaya göre
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _search();
    });
  }

  void _search() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      if (_searchByCity) {
        _results = _searchService.searchByCity(query);
      } else {
        _results = _searchService.searchByPlate(query);
      }
    });
  }

  void _toggleSearchMode() {
    setState(() {
      _searchByCity = !_searchByCity;
      _searchController.clear();
      _results = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Başlık ve Arama Modu Seçimi
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nerenin Plakası',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Şehir Ara'),
                        icon: Icon(Icons.location_city),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Plaka Ara'),
                        icon: Icon(Icons.directions_car),
                      ),
                    ],
                    selected: <bool>{_searchByCity},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _searchByCity = newSelection.first;
                        _searchController.clear();
                        _results = [];
                      });
                    },
                  ),
                ],
              ),
            ),

            // Arama Çubuğu
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                controller: _searchController,
                hintText: _searchByCity
                    ? 'Şehir adı yazın...'
                    : 'Plaka kodu yazın...',
                leading: const Icon(Icons.search),
                trailing: _isSearching
                    ? [
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _results = [];
                            });
                          },
                        )
                      ]
                    : null,
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16),
                ),
                elevation: MaterialStateProperty.all(4),
              ),
            ),

            // Sonuçlar Listesi
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchByCity
                                ? Icons.location_city
                                : Icons.directions_car,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? _searchByCity
                                    ? 'Şehir adı girerek arama yapın'
                                    : 'Plaka kodu girerek arama yapın'
                                : 'Sonuç bulunamadı',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.grey,
                                    ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                item.plateCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              item.city,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text('Plaka Kodu: ${item.plateCode}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
