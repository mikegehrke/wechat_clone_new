import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ChatGamesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // CHAT GAMES
  // ============================================================================

  /// Start Tic-Tac-Toe game
  static Future<String> startTicTacToe({
    required String chatId,
    required String userId,
    required String opponentId,
  }) async {
    try {
      final gameData = {
        'type': 'tictactoe',
        'chatId': chatId,
        'player1': userId,
        'player2': opponentId,
        'currentTurn': userId,
        'board': List.filled(9, ''),
        'winner': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('chat_games').add(gameData);

      // Send game message
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': userId,
        'type': 'game',
        'content': '🎮 Started Tic-Tac-Toe',
        'metadata': {
          'gameId': docRef.id,
          'gameType': 'tictactoe',
        },
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start game: $e');
    }
  }

  /// Make move in Tic-Tac-Toe
  static Future<void> makeTicTacToeMove({
    required String gameId,
    required String userId,
    required int position,
  }) async {
    try {
      final gameDoc = await _firestore.collection('chat_games').doc(gameId).get();
      final data = gameDoc.data()!;
      
      final board = List<String>.from(data['board']);
      final currentTurn = data['currentTurn'];
      final player1 = data['player1'];
      final player2 = data['player2'];

      if (userId != currentTurn) {
        throw Exception('Not your turn');
      }

      if (board[position].isNotEmpty) {
        throw Exception('Position already taken');
      }

      // Make move
      board[position] = userId == player1 ? 'X' : 'O';

      // Check winner
      final winner = _checkTicTacToeWinner(board);

      // Update game
      await _firestore.collection('chat_games').doc(gameId).update({
        'board': board,
        'currentTurn': userId == player1 ? player2 : player1,
        'winner': winner,
        'isActive': winner == null && !board.contains(''),
      });
    } catch (e) {
      throw Exception('Failed to make move: $e');
    }
  }

  static String? _checkTicTacToeWinner(List<String> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];

      if (a.isNotEmpty && a == b && b == c) {
        return a;
      }
    }

    return null;
  }

  /// Start Dice game
  static Future<String> rollDice({
    required String chatId,
    required String userId,
  }) async {
    try {
      final random = Random();
      final result = random.nextInt(6) + 1;

      final gameData = {
        'type': 'dice',
        'chatId': chatId,
        'userId': userId,
        'result': result,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('chat_games').add(gameData);

      // Send game message
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': userId,
        'type': 'game',
        'content': '🎲 Rolled: $result',
        'metadata': {
          'gameId': docRef.id,
          'gameType': 'dice',
          'result': result,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to roll dice: $e');
    }
  }

  /// Get game details
  static Stream<Map<String, dynamic>> getGameStream(String gameId) {
    return _firestore
        .collection('chat_games')
        .doc(gameId)
        .snapshots()
        .map((doc) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    });
  }
}
