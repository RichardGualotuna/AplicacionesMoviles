import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_message.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HistoryItem> _allHistory = [];
  List<HistoryItem> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_filterHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    // Mock data - en una app real vendría de la base de datos
    _allHistory = [
      HistoryItem(
        id: '1',
        question: '¿Qué fertilizante debo aplicar en la etapa de floración?',
        answer: 'Para la floración del maíz en Cotopaxi, recomiendo 60 kg N/ha + 30 kg P2O5/ha usando Urea (46-0-0) + Fosfato diamónico...',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        crop: 'Maíz',
        location: 'Cotopaxi',
      ),
      HistoryItem(
        id: '2',
        question: '¿Cómo controlar el gusano cogollero?',
        answer: 'Para el control del gusano cogollero, utiliza trampas de feromonas y aplicación de Bacillus thuringiensis...',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        crop: 'Maíz',
        location: 'Cotopaxi',
      ),
      HistoryItem(
        id: '3',
        question: '¿Cuándo debo cosechar el maíz?',
        answer: 'La cosecha del maíz se realiza cuando los granos tienen 14-16% de humedad, aproximadamente 120-140 días después de la siembra...',
        timestamp: DateTime.now().subtract(const Duration(days: 14)),
        crop: 'Maíz',
        location: 'Cotopaxi',
      ),
      HistoryItem(
        id: '4',
        question: '¿Qué cantidad de agua necesita el cultivo?',
        answer: 'El maíz requiere aproximadamente 500-700mm de agua durante todo su ciclo, distribuidos según la etapa fenológica...',
        timestamp: DateTime.now().subtract(const Duration(days: 21)),
        crop: 'Maíz',
        location: 'Cotopaxi',
      ),
      HistoryItem(
        id: '5',
        question: '¿Cuál es la mejor época para sembrar papa?',
        answer: 'En la sierra ecuatoriana, la mejor época para sembrar papa es durante los meses de marzo-abril y septiembre-octubre...',
        timestamp: DateTime.now().subtract(const Duration(days: 60)),
        crop: 'Papa',
        location: 'Chimborazo',
      ),
    ];
    
    _filteredHistory = List.from(_allHistory);
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredHistory = List.from(_allHistory);
      } else {
        _filteredHistory = _allHistory.where((item) {
          return item.question.toLowerCase().contains(query) ||
                 item.answer.toLowerCase().contains(query) ||
                 item.crop.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Historial de Consultas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearHistoryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '🔍 Buscar en historial...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textGray),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textGray),
                        onPressed: () {
                          _searchController.clear();
                          _filterHistory();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // History list
          Expanded(
            child: _filteredHistory.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = _filteredHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.question,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    item.crop,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getTimeAgo(item.timestamp),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Respuesta:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.answer,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textGray,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '📍 ${item.location}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(item.timestamp),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                isSearching ? Icons.search_off : Icons.history,
                size: 40,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'No se encontraron resultados' : 'No hay historial',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isSearching 
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Tus consultas anteriores aparecerán aquí',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Estás seguro de que deseas eliminar todo el historial de consultas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allHistory.clear();
                _filteredHistory.clear();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historial eliminado'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return 'Hace ${(difference.inDays / 7).floor()}sem';
    } else {
      return 'Hace ${(difference.inDays / 30).floor()}mes';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class HistoryItem {
  final String id;
  final String question;
  final String answer;
  final DateTime timestamp;
  final String crop;
  final String location;

  HistoryItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.timestamp,
    required this.crop,
    required this.location,
  });
}