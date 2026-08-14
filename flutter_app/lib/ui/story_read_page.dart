import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/capitulo.dart';
import '../models/cuento.dart';
import '../services/capitulo_service.dart';
import '../theme/willpig_colors.dart';
import '../widgets/html_text.dart';

class StoryReadPage extends StatefulWidget {
  const StoryReadPage({required this.cuento, super.key});

  final Cuento cuento;

  @override
  State<StoryReadPage> createState() => _StoryReadPageState();
}

class _StoryReadPageState extends State<StoryReadPage> {
  late final CapituloService _capituloService;
  late Future<List<Capitulo>> _capitulos;

  final _scrollController = ScrollController();
  final _storage = const FlutterSecureStorage();

  // Opciones de lectura configurables (por defecto tema oscuro)
  double _fontSize = 16.0;
  String _fontFamily = 'Serif';
  double _lineHeight = 1.6;
  String _selectedTheme = 'dark';
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _capituloService = CapituloService(Supabase.instance.client);
    _capitulos = _capituloService.fetchCapitulos(widget.cuento.id);

    _loadPreferences();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    setState(() {
      _scrollProgress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    });
  }

  Future<void> _loadPreferences() async {
    final size = await _storage.read(key: 'reader_font_size');
    final family = await _storage.read(key: 'reader_font_family');
    final height = await _storage.read(key: 'reader_line_height');
    final theme = await _storage.read(key: 'reader_theme');

    if (mounted) {
      setState(() {
        if (size != null) _fontSize = double.tryParse(size) ?? 16.0;
        if (family != null) _fontFamily = family;
        if (height != null) _lineHeight = double.tryParse(height) ?? 1.6;
        if (theme != null) _selectedTheme = theme;
      });
    }
  }

  Future<void> _savePreference(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Color get _backgroundColor {
    switch (_selectedTheme) {
      case 'cream':
        return const Color(0xFFFAF6F0);
      case 'sepia':
        return const Color(0xFFF4ECD8);
      case 'dark':
      default:
        return const Color(0xFF121212);
    }
  }

  Color get _textColor {
    switch (_selectedTheme) {
      case 'cream':
        return const Color(0xFF2B1100);
      case 'sepia':
        return const Color(0xFF5B4636);
      case 'dark':
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  String get _systemFont {
    switch (_fontFamily) {
      case 'Sans-serif':
        return 'sans-serif';
      case 'Monospace':
        return 'monospace';
      case 'Serif':
      default:
        return 'serif';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.cuento.titulo,
          style: TextStyle(
            color: _selectedTheme == 'dark' ? Colors.white : _textColor,
          ),
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _selectedTheme == 'dark' ? Colors.white : _textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.text_fields_rounded,
              color: _selectedTheme == 'dark' ? Colors.white : _textColor,
            ),
            tooltip: 'Opciones de lectura',
            onPressed: _showAppearanceSettings,
          ),
        ],
        // Barra de progreso de lectura debajo del AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: _scrollProgress,
              backgroundColor: _backgroundColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                WillpigColors.primarySalmon,
              ),
              minHeight: 3,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Capitulo>>(
        future: _capitulos,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  WillpigColors.primarySalmon,
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: WillpigColors.danger,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error al cargar contenido:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _textColor),
                    ),
                  ],
                ),
              ),
            );
          }

          final capitulos = snapshot.data ?? [];
          if (capitulos.isEmpty) {
            return Center(
              child: Text(
                'Esta historia aún no tiene contenido.',
                style: TextStyle(color: _textColor, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
            itemCount: capitulos.length,
            itemBuilder: (context, index) {
              final cap = capitulos[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cap.titulo.isNotEmpty && cap.titulo != 'Sin título') ...[
                    Text(
                      cap.titulo,
                      style: TextStyle(
                        fontSize: _fontSize + 6,
                        fontWeight: FontWeight.bold,
                        fontFamily: _systemFont,
                        color: _selectedTheme == 'dark'
                            ? Colors.white
                            : _textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  HtmlText(
                    cap.contenido,
                    textStyle: TextStyle(
                      fontSize: _fontSize,
                      height: _lineHeight,
                      fontFamily: _systemFont,
                      color: _textColor,
                    ),
                  ),
                  if (index < capitulos.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Divider(color: _textColor.withValues(alpha: 0.12)),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAppearanceSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _selectedTheme == 'dark'
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDarkSheet = _selectedTheme == 'dark';
            final sheetTextColor = isDarkSheet ? Colors.white : Colors.black87;
            final sheetLabelColor = isDarkSheet
                ? Colors.white70
                : Colors.black54;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkSheet ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Opciones de lectura',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: sheetTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tema de lectura
                    Text(
                      'Tema',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: sheetLabelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _themeOptionButton(
                          setSheetState,
                          id: 'dark',
                          label: 'Oscuro',
                          bg: const Color(0xFF121212),
                          text: Colors.white,
                          border: Colors.white24,
                        ),
                        _themeOptionButton(
                          setSheetState,
                          id: 'cream',
                          label: 'Crema',
                          bg: const Color(0xFFFAF6F0),
                          text: const Color(0xFF2B1100),
                          border: Colors.black12,
                        ),
                        _themeOptionButton(
                          setSheetState,
                          id: 'sepia',
                          label: 'Sepia',
                          bg: const Color(0xFFF4ECD8),
                          text: const Color(0xFF5B4636),
                          border: Colors.black12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tamaño de letra
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tamaño de letra',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: sheetLabelColor,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _fontSize > 14.0
                                  ? () {
                                      setState(() => _fontSize -= 2.0);
                                      setSheetState(() {});
                                      _savePreference(
                                        'reader_font_size',
                                        _fontSize.toString(),
                                      );
                                    }
                                  : null,
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: _fontSize > 14.0
                                    ? WillpigColors.primarySalmon
                                    : sheetTextColor.withValues(alpha: 0.3),
                              ),
                            ),
                            Text(
                              '${_fontSize.toInt()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: sheetTextColor,
                              ),
                            ),
                            IconButton(
                              onPressed: _fontSize < 26.0
                                  ? () {
                                      setState(() => _fontSize += 2.0);
                                      setSheetState(() {});
                                      _savePreference(
                                        'reader_font_size',
                                        _fontSize.toString(),
                                      );
                                    }
                                  : null,
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: _fontSize < 26.0
                                    ? WillpigColors.primarySalmon
                                    : sheetTextColor.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Familia tipográfica
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tipografía',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: sheetLabelColor,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _fontFamily,
                          dropdownColor: isDarkSheet
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          style: TextStyle(
                            color: sheetTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          underline: Container(
                            height: 1.5,
                            color: WillpigColors.primarySalmon,
                          ),
                          onChanged: (String? val) {
                            if (val != null) {
                              setState(() => _fontFamily = val);
                              setSheetState(() {});
                              _savePreference('reader_font_family', val);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'Serif',
                              child: Text('Serif'),
                            ),
                            DropdownMenuItem(
                              value: 'Sans-serif',
                              child: Text('Sans-serif'),
                            ),
                            DropdownMenuItem(
                              value: 'Monospace',
                              child: Text('Monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Espaciado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Interlineado',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: sheetLabelColor,
                          ),
                        ),
                        Row(
                          children: [
                            _lineHeightButton(
                              setSheetState,
                              value: 1.3,
                              label: 'Corto',
                            ),
                            const SizedBox(width: 8),
                            _lineHeightButton(
                              setSheetState,
                              value: 1.6,
                              label: 'Medio',
                            ),
                            const SizedBox(width: 8),
                            _lineHeightButton(
                              setSheetState,
                              value: 2.0,
                              label: 'Largo',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _themeOptionButton(
    void Function(void Function()) setSheetState, {
    required String id,
    required String label,
    required Color bg,
    required Color text,
    required Color border,
  }) {
    final isSelected = _selectedTheme == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTheme = id);
        setSheetState(() {});
        _savePreference('reader_theme', id);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? WillpigColors.primarySalmon : border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: text,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _lineHeightButton(
    void Function(void Function()) setSheetState, {
    required double value,
    required String label,
  }) {
    final isSelected = _lineHeight == value;
    final isDarkSheet = _selectedTheme == 'dark';

    return GestureDetector(
      onTap: () {
        setState(() => _lineHeight = value);
        setSheetState(() {});
        _savePreference('reader_line_height', value.toString());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? WillpigColors.primarySalmon
              : (isDarkSheet
                    ? const Color(0xFF2C2C2C)
                    : Colors.black12.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? WillpigColors.inkBlack
                : (isDarkSheet ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
