import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Velha Estiloso',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  String currentPlayer = 'X';
  String winner = '';
  bool isTimerEnabled = true;
  int timeLeft = 30;
  Timer? timer;
  bool gameOver = false;
  late ConfettiController _confettiController;
  bool audioEnabled = true;
  String? timerAudioPath;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    if (isTimerEnabled) startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    if (audioEnabled && timerAudioPath != null) {
      _audioPlayer.play(DeviceFileSource(timerAudioPath!));
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          // Time's up, switch player
          switchPlayer();
        }
      });
    });
  }

  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      if (isTimerEnabled) startTimer();
    });
  }

  void makeMove(int row, int col) {
    if (board[row][col] == '' && winner == '' && !gameOver) {
      setState(() {
        board[row][col] = currentPlayer;
        if (checkWinner(row, col)) {
          winner = currentPlayer;
          gameOver = true;
          timer?.cancel();
          _confettiController.play();
        } else if (isBoardFull()) {
          winner = 'Empate';
          gameOver = true;
          timer?.cancel();
        } else {
          switchPlayer();
        }
      });
    }
  }

  bool checkWinner(int row, int col) {
    // Check row
    if (board[row].every((cell) => cell == currentPlayer)) return true;
    // Check column
    if (board.every((r) => r[col] == currentPlayer)) return true;
    // Check diagonals
    if (row == col && board.every((r) => r[board.indexOf(r)] == currentPlayer))
      return true;
    if (row + col == 2 &&
        board.every((r) => r[2 - board.indexOf(r)] == currentPlayer))
      return true;
    return false;
  }

  bool isBoardFull() {
    return board.every((row) => row.every((cell) => cell != ''));
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      currentPlayer = 'X';
      winner = '';
      gameOver = false;
      if (isTimerEnabled) startTimer();
    });
  }

  void toggleTimer(bool value) {
    setState(() {
      isTimerEnabled = value;
      if (isTimerEnabled && !gameOver) {
        startTimer();
      } else {
        timer?.cancel();
      }
    });
  }

  Future<void> _pickTimerAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        timerAudioPath = result.files.single.path;
      });
    }
  }

  void toggleAudio(bool value) {
    setState(() {
      audioEnabled = value;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo da Velha Estiloso'),
        backgroundColor: Colors.blueAccent,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_music),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MediaPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlueAccent,
                  Colors.purpleAccent,
                  Colors.white
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              currentPlayer == 'X' ? Colors.blue : Colors.red,
                        ),
                        child: Text('Jogador: $currentPlayer'),
                      ),
                      if (isTimerEnabled)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: timeLeft < 10 ? Colors.red : Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            'Tempo: $timeLeft s',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Temporizador: ',
                          style: TextStyle(fontSize: 18)),
                      Switch(
                        value: isTimerEnabled,
                        onChanged: toggleTimer,
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Áudio: ', style: TextStyle(fontSize: 18)),
                      Switch(
                        value: audioEnabled,
                        onChanged: toggleAudio,
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isTimerEnabled)
                    ElevatedButton(
                      onPressed: _pickTimerAudio,
                      child: const Text('Selecionar Áudio do Temporizador'),
                    ),
                  if (timerAudioPath != null)
                    Text(
                        'Áudio selecionado: ${timerAudioPath!.split('/').last}',
                        style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        int row = index ~/ 3;
                        int col = index % 3;
                        bool isPlaced = board[row][col] != '';
                        return GestureDetector(
                          onTap: () => makeMove(row, col),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            transform: isPlaced
                                ? Matrix4.diagonal3Values(1.2, 1.2, 1)
                                : Matrix4.identity(),
                            decoration: BoxDecoration(
                              color: board[row][col] == ''
                                  ? Colors.grey[300]
                                  : (board[row][col] == 'X'
                                      ? Colors.blueAccent
                                      : Colors.redAccent),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isPlaced
                                  ? [
                                      BoxShadow(
                                        color: board[row][col] == 'X'
                                            ? Colors.blue.withOpacity(0.7)
                                            : Colors.red.withOpacity(0.7),
                                        blurRadius: 25.0,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : [],
                              border: Border.all(
                                color: isPlaced ? Colors.white : Colors.black12,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: isPlaced ? 1.0 : 0.7,
                                duration: const Duration(milliseconds: 300),
                                child: AnimatedScale(
                                  scale: isPlaced ? 1.0 : 0.8,
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    board[row][col],
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: isPlaced
                                          ? [
                                              Shadow(
                                                blurRadius: 15.0,
                                                color: Colors.black54,
                                                offset: const Offset(3, 3),
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (winner != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            winner == 'Empate'
                                ? 'Empate!'
                                : 'Vencedor: $winner',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: winner == 'X' ? Colors.blue : Colors.red,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black45,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                    ),
                    child: const Text('Reiniciar Jogo'),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.yellow,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  File? _image;
  String? _audioPath;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
      });
    }
  }

  void _playAudio() async {
    if (_audioPath != null) {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
    }
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Mídia'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Selecionar Imagem'),
            ),
            const SizedBox(height: 20),
            if (_image != null) Image.file(_image!, height: 200),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _pickAudio,
              child: const Text('Selecionar Áudio MP3'),
            ),
            const SizedBox(height: 20),
            if (_audioPath != null)
              Text('Áudio selecionado: ${_audioPath!.split('/').last}'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _playAudio,
                  child: const Text('Tocar Áudio'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopAudio,
                  child: const Text('Parar Áudio'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
