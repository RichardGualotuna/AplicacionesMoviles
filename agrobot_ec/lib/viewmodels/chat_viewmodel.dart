import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoading = false;
  String _currentCrop = 'Maíz';
  String _currentLocation = 'Cotopaxi';

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  String get currentCrop => _currentCrop;
  String get currentLocation => _currentLocation;

  // Quick suggestions
  List<String> get quickSuggestions => [
    'Control de plagas',
    'Riego óptimo',
    'Época de cosecha',
    'Fertilización',
  ];

  ChatViewModel() {
    _initializeChat();
  }

  void _initializeChat() {
    _messages = [
      ChatMessage(
        id: '1',
        text: '¡Hola! Soy tu asistente agrícola. Estoy aquí para ayudarte con tu cultivo de $_currentCrop en $_currentLocation. ¿En qué puedo asistirte hoy?',
        isFromUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Add bot response
    final botMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: _generateBotResponse(text),
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(botMessage);
    _isTyping = false;
    notifyListeners();
  }

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('fertilizante') || message.contains('fertilización')) {
      return '''Para la fertilización del $_currentCrop en $_currentLocation (2800 msnm), te recomiendo:

📊 **Dosis:** 60 kg N/ha + 30 kg P2O5/ha
🌱 **Fertilizante:** Urea (46-0-0) + Fosfato diamónico
⏰ **Momento:** Al inicio de la floración (V12-V14)

¿Necesitas más detalles sobre la aplicación?''';
    }
    
    if (message.contains('plaga') || message.contains('gusano')) {
      return '''Para el control de plagas en $_currentCrop:

🐛 **Gusano cogollero:** Usar trampas de feromonas y Bacillus thuringiensis
🕷️ **Ácaros:** Aplicar aceite neem cada 15 días
🦗 **Trips:** Trampas cromáticas azules

**Importante:** Monitoreo semanal y rotación de productos.''';
    }
    
    if (message.contains('riego') || message.contains('agua')) {
      return '''Recomendaciones de riego para $_currentCrop en $_currentLocation:

💧 **Frecuencia:** Cada 3-4 días en época seca
⏰ **Horario:** Temprano en la mañana (6-8 AM)
📏 **Cantidad:** 25-30 mm por semana
🌡️ **Evitar:** Riego en horas de calor intenso''';
    }
    
    return '''Gracias por tu consulta sobre $_currentCrop. Basándome en las condiciones de $_currentLocation, te recomiendo consultar nuestras guías técnicas específicas.

¿Podrías ser más específico sobre qué aspecto del cultivo te interesa? Por ejemplo:
- Fertilización
- Control de plagas
- Manejo del riego
- Época de siembra''';
  }

  void setCropAndLocation(String crop, String location) {
    _currentCrop = crop;
    _currentLocation = location;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _initializeChat();
    notifyListeners();
  }

  void sendQuickSuggestion(String suggestion) {
    sendMessage('¿Cómo puedo mejorar el $suggestion de mi $_currentCrop?');
  }
}