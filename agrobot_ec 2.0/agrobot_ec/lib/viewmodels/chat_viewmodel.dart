import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa el paquete http
import '../models/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoading = false;
  String _currentCrop = 'Maíz';
  String _currentLocation = 'Cotopaxi';
  final String _apiUrl = 'http://127.0.0.1:8000/chat'; // URL de tu API

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

    try {
      // Configurar la llamada a la API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': text}), // Envía el mensaje del usuario como JSON
      );

      if (response.statusCode == 200) {
        // Parsear la respuesta JSON del backend
        final responseData = jsonDecode(response.body);
        final botResponseText = responseData['response'];

        // Add bot response
        final botMessage = ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: botResponseText,
          isFromUser: false,
          timestamp: DateTime.now(),
        );

        _messages.add(botMessage);
      } else {
        // Manejar errores de la API
        _messages.add(ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: 'Error al conectar con el servidor. Código de estado: ${response.statusCode}',
          isFromUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      // Manejar errores de conexión
      _messages.add(ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: 'Error de conexión: $e. Asegúrate de que el servidor backend esté en ejecución.',
        isFromUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      // Finalizar la escritura
      _isTyping = false;
      notifyListeners();
    }
  }

  // Las siguientes funciones se mantienen igual
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
