import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../home/domain/home_models.dart';

/// OpenAI Service for GPT-4o powered styling recommendations
class OpenAIService {
  final Dio _dio;

  OpenAIService() : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {
        'Authorization': 'Bearer $openAiKey',
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Get styling recommendation from GPT-4o
  /// Analyzes the user's outfit image and recommends a product from the catalog
  /// Returns the product ID as a string, or null on error
  Future<String?> getStylingRecommendation(
    File image,
    List<HomeProduct> catalog,
  ) async {
    try {
      // Convert image to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Convert catalog to JSON string
      final catalogJson = catalog.map((HomeProduct p) => {
        'id': p.id,
        'name': p.productName,
        'brand': p.brandName,
        'material': p.material,
        'price': p.price,
        'vibe': p.vibe,
      }).toList();
      final catalogString = jsonEncode(catalogJson);

      // Build messages
      final messages = [
        {
          'role': 'system',
          'content': '''You are a high-end fashion stylist for AURAMIKA. 
Analyze the user's outfit image. From the provided JSON catalog, select the SINGLE ONE item that best complements their look. 
Return ONLY the product ID as a plain string. No markdown, no json.''',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'Here is the outfit image. Start analyzing. Here is the catalog: $catalogString',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ];

      // Make API call
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': messages,
          'max_tokens': 50,
        },
      );

      // Parse response
      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'] as String;
        final productId = content.trim();
        
        // Validate that it's a valid product ID
        if (catalog.any((p) => p.id == productId)) {
          return productId;
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('OpenAI API Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('OpenAI Error: $e');
      return null;
    }
  }
}
