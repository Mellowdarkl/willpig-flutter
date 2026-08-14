import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../models/cuento.dart';
import '../services/cuento_service.dart';
import '../widgets/story_card.dart';
import '../theme/willpig_colors.dart';
import 'story_read_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.authController,
    required this.cuentoService,
    super.key,
  });

  final AuthController authController;
  final CuentoService cuentoService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Cuento>> _cuentos;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _cuentos = widget.cuentoService.fetchCuentos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _cuentos = widget.cuentoService.fetchCuentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final userName = user?.name ?? 'Lector';

    return Scaffold(
      backgroundColor: WillpigColors.bgOuter,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              color: WillpigColors.primarySalmon,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'WillPig',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.authController.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: FutureBuilder<List<Cuento>>(
        future: _cuentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 48,
                      color: WillpigColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudieron cargar los cuentos.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allCuentos = snapshot.data ?? [];

          // Obtener categorías únicas dinámicamente
          final categories = <String>{};
          for (final c in allCuentos) {
            if (c.categoria != null && c.categoria!.isNotEmpty) {
              categories.add(c.categoria!);
            }
          }

          // Filtrar cuentos según búsqueda y categoría seleccionada
          final filteredCuentos = allCuentos.where((cuento) {
            final matchesCategory =
                _selectedCategory == null ||
                cuento.categoria == _selectedCategory;

            final matchesSearch =
                _searchQuery.isEmpty ||
                cuento.titulo.toLowerCase().contains(_searchQuery) ||
                (cuento.autor != null &&
                    cuento.autor!.toLowerCase().contains(_searchQuery));

            return matchesCategory && matchesSearch;
          }).toList();

          // Elegir cuento destacado para "Recomendación del día" (el más visto)
          Cuento? featuredCuento;
          if (allCuentos.isNotEmpty) {
            featuredCuento = allCuentos.reduce(
              (a, b) => a.vistas > b.vistas ? a : b,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            color: WillpigColors.primarySalmon,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saludo personalizado al usuario
                        Text(
                          '¡Hola, $userName!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: WillpigColors.primarySalmon,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Biblioteca',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Buscador al estilo de la barra de navegación web
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: WillpigColors.bgLight,
                                  borderRadius: BorderRadius.circular(
                                    WillpigColors.radiusSm,
                                  ),
                                  border: Border.all(
                                    color: WillpigColors.border,
                                  ),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar historias o autores...',
                                    hintStyle: const TextStyle(
                                      color: WillpigColors.textMuted,
                                      fontSize: 14,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val.trim().toLowerCase();
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchQuery = _searchController.text
                                      .trim()
                                      .toLowerCase();
                                });
                              },
                              child: Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: WillpigColors.primarySalmon,
                                  borderRadius: BorderRadius.circular(
                                    WillpigColors.radiusSm,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: WillpigColors.inkBlack,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recomendación del día (Banner tipo web)
                if (featuredCuento != null &&
                    _searchQuery.isEmpty &&
                    _selectedCategory == null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: WillpigColors.bgLight,
                          borderRadius: BorderRadius.circular(
                            WillpigColors.radiusLg,
                          ),
                          border: Border.all(color: WillpigColors.border),
                          boxShadow: WillpigColors.shadowSoft,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Portada a la izquierda
                              Container(
                                width: 100,
                                decoration: const BoxDecoration(
                                  color: WillpigColors.primarySalmonMuted,
                                ),
                                child:
                                    featuredCuento.portadaUrl != null &&
                                        featuredCuento.portadaUrl!.isNotEmpty
                                    ? Image.network(
                                        featuredCuento.portadaUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Center(
                                          child: Icon(
                                            Icons.auto_stories,
                                            color: Colors.white70,
                                            size: 28,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.auto_stories,
                                          color: Colors.white70,
                                          size: 28,
                                        ),
                                      ),
                              ),
                              // Información a la derecha
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Recomendación del día',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: WillpigColors.primarySalmon,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        featuredCuento.titulo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (featuredCuento.descripcion != null &&
                                          featuredCuento
                                              .descripcion!
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          featuredCuento.descripcion!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: WillpigColors.textMuted,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${featuredCuento.vistas} lecturas',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: WillpigColors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  WillpigColors.primarySalmon,
                                              foregroundColor:
                                                  WillpigColors.inkBlack,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 0,
                                                  ),
                                              minimumSize: const Size(0, 32),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(99),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => StoryReadPage(
                                                    cuento: featuredCuento!,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Comenzar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Filtro de categorías (Carrusel horizontal estilo web)
                if (categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _categoryChip(
                            label: 'Todas',
                            isSelected: _selectedCategory == null,
                            onTap: () =>
                                setState(() => _selectedCategory = null),
                          ),
                          ...categories.map(
                            (cat) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _categoryChip(
                                label: cat,
                                isSelected: _selectedCategory == cat,
                                onTap: () =>
                                    setState(() => _selectedCategory = cat),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Cuadrícula de cuentos
                if (filteredCuentos.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Aún no hay historias publicadas o no coinciden con la búsqueda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: WillpigColors.textMuted),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final cuento = filteredCuentos[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoryReadPage(cuento: cuento),
                            ),
                          ),
                          child: StoryCard(cuento: cuento),
                        );
                      }, childCount: filteredCuentos.length),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 185,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 310,
                          ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? WillpigColors.primarySalmon
              : WillpigColors.bgLight,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? Colors.transparent : WillpigColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? WillpigColors.inkBlack : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
