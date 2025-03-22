import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/sudoku_board.dart';

class ImageProcessor {
  // Extract a Sudoku puzzle from an image
  static Future<List<List<int>>?> extractSudokuFromImage(String imagePath, int size) async {
    try {
      final File imageFile = File(imagePath);
      final InputImage inputImage = InputImage.fromFile(imageFile);
      
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      // Process the recognized text to extract Sudoku grid
      List<List<int>> grid = await _processSudokuText(recognizedText, size);
      
      // Free resources
      textRecognizer.close();
      
      return grid;
    } catch (e) {
      print('Error extracting Sudoku from image: $e');
      return null;
    }
  }
  
  // Process recognized text to extract Sudoku grid
  static Future<List<List<int>>> _processSudokuText(RecognizedText recognizedText, int size) async {
    // Create an empty grid
    List<List<int>> grid = List.generate(
      size,
      (_) => List.generate(size, (_) => 0),
    );
    
    // Sort text blocks by position (top to bottom, left to right)
    List<TextBlock> sortedBlocks = recognizedText.blocks.toList()
      ..sort((a, b) {
        // Sort by Y first (row)
        if ((a.boundingBox.top - b.boundingBox.top).abs() > 20) {
          return a.boundingBox.top.compareTo(b.boundingBox.top);
        }
        // Then by X (column)
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      });
    
    // Attempt to identify grid structure
    if (sortedBlocks.isEmpty) {
      return grid;
    }
    
    // Find grid bounds
    double? minX, maxX, minY, maxY;
    for (var block in sortedBlocks) {
      minX = minX == null ? block.boundingBox.left : 
             (block.boundingBox.left < minX ? block.boundingBox.left : minX);
      maxX = maxX == null ? block.boundingBox.right : 
             (block.boundingBox.right > maxX ? block.boundingBox.right : maxX);
      minY = minY == null ? block.boundingBox.top : 
             (block.boundingBox.top < minY ? block.boundingBox.top : minY);
      maxY = maxY == null ? block.boundingBox.bottom : 
             (block.boundingBox.bottom > maxY ? block.boundingBox.bottom : maxY);
    }
    
    if (minX == null || maxX == null || minY == null || maxY == null) {
      return grid;
    }
    
    double gridWidth = maxX - minX;
    double gridHeight = maxY - minY;
    
    // Calculate cell size
    double cellWidth = gridWidth / size;
    double cellHeight = gridHeight / size;
    
    // Assign detected numbers to grid positions
    for (var block in sortedBlocks) {
      // Get the center of the text block
      double centerX = block.boundingBox.left + block.boundingBox.width / 2;
      double centerY = block.boundingBox.top + block.boundingBox.height / 2;
      
      // Calculate grid position
      int col = ((centerX - minX) / cellWidth).floor();
      int row = ((centerY - minY) / cellHeight).floor();
      
      // Ensure position is within grid bounds
      if (row >= 0 && row < size && col >= 0 && col < size) {
        // Extract number
        String text = block.text.trim();
        int? number = _extractNumber(text);
        
        if (number != null && number >= 1 && number <= size) {
          grid[row][col] = number;
        }
      }
    }
    
    return grid;
  }
  
  // Extract a number from text
  static int? _extractNumber(String text) {
    // Remove all non-digit characters
    String digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.isEmpty) {
      return null;
    }
    
    // Take the first digit if there are multiple
    return int.tryParse(digitsOnly[0]);
  }
}