import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2A2D36),
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  List<String> _history = [];

  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        _expression = '';
        _result = '0';
      } else if (text == '=') {
        try {
          if (_expression.isNotEmpty) {
            double evalResult = _evaluate(_expression);
            _result = _formatResult(evalResult);
            _history.add('$_expression = $_result');
            // optionally reset expression
          }
        } catch (e) {
          _result = 'Error';
        }
      } else {
        if (_result != '0' && _result != 'Error' && _expression.isEmpty) {
          // If we had a result and start typing operators, continue from result
          if ('+-x÷mod√'.contains(text)) {
            _expression = _result + text;
          } else {
            _expression = text;
            _result = '0';
          }
        } else {
          _expression += text;
        }
      }
    });
  }

  String _formatResult(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    // Simple formatting to avoid excessive decimals
    String res = val.toStringAsFixed(6);
    return res.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  double _evaluate(String expr) {
    expr = expr.replaceAll('x', '*').replaceAll('÷', '/').replaceAll(',', '');

    // Evaluate √
    while (expr.contains('√')) {
      var match = RegExp(r'√(\d+\.?\d*)').firstMatch(expr);
      if (match != null) {
        double val = double.parse(match.group(1)!);
        expr = expr.replaceRange(match.start, match.end, sqrt(val).toString());
      } else {
        break; // safe exit
      }
    }

    // Tokenize
    List<String> tokens = [];
    String current = '';
    for (int i = 0; i < expr.length; i++) {
      String c = expr[i];
      if (expr.startsWith('mod', i)) {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        tokens.add('mod');
        i += 2;
      } else if ('+-*/'.contains(c)) {
        if (c == '-' && (i == 0 || '+-*/mod'.contains(expr[i - 1]))) {
          current += c;
        } else {
          if (current.isNotEmpty) {
            tokens.add(current);
            current = '';
          }
          tokens.add(c);
        }
      } else {
        current += c;
      }
    }
    if (current.isNotEmpty) {
      tokens.add(current);
    }

    // Process '*', '/', 'mod'
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/' || tokens[i] == 'mod') {
        double a = double.parse(tokens[i - 1]);
        double b = double.parse(tokens[i + 1]);
        double res = 0;
        if (tokens[i] == '*') res = a * b;
        if (tokens[i] == '/') res = a / b;
        if (tokens[i] == 'mod') res = a % b;
        tokens.replaceRange(i - 1, i + 2, [res.toString()]);
        i -= 2; // adjust index
      }
    }

    // Process '+', '-'
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '+' || tokens[i] == '-') {
        double a = double.parse(tokens[i - 1]);
        double b = double.parse(tokens[i + 1]);
        double res = 0;
        if (tokens[i] == '+') res = a + b;
        if (tokens[i] == '-') res = a - b;
        tokens.replaceRange(i - 1, i + 2, [res.toString()]);
        i -= 2;
      }
    }

    return double.parse(tokens[0]);
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D36),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'History Penjumlahan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.blueAccent),
                        onPressed: () {
                          setState(() {
                            _history.clear();
                          });
                          setModalState(() {}); // update modal UI
                        },
                      )
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: _history.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada history',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  _history[index],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildButton(String text,
      {Color? bgColor, Color? textColor, int flex = 1}) {
    // Determine colors based on text if not provided
    if (bgColor == null) {
      if ('÷x-+=mod'.contains(text)) {
        bgColor = const Color(0xFF4285F4); // Blue for operators
      } else {
        bgColor = const Color(0xFF3E414B); // Dark grey
      }
    }
    if (textColor == null) {
      textColor = Colors.white;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: () => _onPressed(text),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Row (History Icon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E414B).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.history, color: Colors.white70),
                      onPressed: _showHistory,
                    ),
                  )
                ],
              ),
            ),
            // Display Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: const TextStyle(
                        color: Color(0xFF9497A0),
                        fontSize: 28,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Keypad Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('C'),
                      _buildButton('√'),
                      _buildButton('mod'),
                      _buildButton('÷'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('x'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('-'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('+'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('0', flex: 2),
                      _buildButton('.'),
                      _buildButton('='),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
