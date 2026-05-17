import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  String input = '';
  String result = '0';

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '0';
      } else if (value == '⌫') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == '=') {
        try {
          result = evaluateExpression(input);
        } catch (e) {
          result = 'Error';
        }
      } else {
        if (_isOperator(value)) {
          if (input.isEmpty) {
            if (value != '-') return;
          } else {
            final last = input[input.length - 1];
            if (_isOperator(last) && value != '-') {
              input = input.substring(0, input.length - 1) + value;
              return;
            }
          }
        }
        input += value;
      }
    });
  }

  bool _isOperator(String s) {
    return s == '+' || s == '-' || s == '×' || s == '÷' || s == '*' || s == '/';
  }

  String evaluateExpression(String exp) {
    if (exp.trim().isEmpty) return '0';
    exp = exp.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      final parser = _ExpressionParser();
      final val = parser.evaluate(exp);
      if (val == val.roundToDouble()) {
        return val.toInt().toString();
      } else {
        return val.toStringAsFixed(5).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
      }
    } catch (_) {
      return 'Error';
    }
  }

  Widget buildButton(String text,
      {Color? color, double flex = 1, Color textColor = Colors.white}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.teal,
            padding: const EdgeInsets.all(18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
          ),
          onPressed: () => buttonPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 22, color: textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFe6f0ff),
        appBar: AppBar(
          title: const Text("Simple Calculator"),
          centerTitle: true,
          backgroundColor: Colors.blue.shade800,
          elevation: 6,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  input.isEmpty ? '0' : input,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 30, color: Colors.black87),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  result,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              const Divider(thickness: 1.2),
              Row(children: [
                buildButton('C', color: Colors.red.shade400),
                buildButton('⌫', color: Colors.grey.shade600),
                buildButton('(', color: Colors.teal),
                buildButton(')', color: Colors.teal),
              ]),
              Row(children: [
                buildButton('7', color: Colors.blue.shade700),
                buildButton('8', color: Colors.blue.shade700),
                buildButton('9', color: Colors.blue.shade700),
                buildButton('÷', color: Colors.orange.shade700),
              ]),
              Row(children: [
                buildButton('4', color: Colors.blue.shade700),
                buildButton('5', color: Colors.blue.shade700),
                buildButton('6', color: Colors.blue.shade700),
                buildButton('×', color: Colors.orange.shade700),
              ]),
              Row(children: [
                buildButton('1', color: Colors.blue.shade700),
                buildButton('2', color: Colors.blue.shade700),
                buildButton('3', color: Colors.blue.shade700),
                buildButton('-', color: Colors.orange.shade700),
              ]),
              Row(children: [
                buildButton('0', color: Colors.blue.shade700),
                buildButton('.', color: Colors.teal),
                buildButton('=', color: Colors.green.shade700, flex: 2),
                buildButton('+', color: Colors.orange.shade700),
              ]),
              const SizedBox(height: 12)
            ],
          ),
        ),
      ),
    );
  }
}


class _ExpressionParser {
  double evaluate(String expression) {
    final tokens = _tokenize(expression);
    final output = <String>[];
    final ops = <String>[];

    int prec(String op) => (op == '+' || op == '-') ? 1 : 2;

    for (var token in tokens) {
      if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(token)) {
        output.add(token);
      } else if ('+-*/'.contains(token)) {
        while (ops.isNotEmpty &&
            '+-*/'.contains(ops.last) &&
            prec(token) <= prec(ops.last)) {
          output.add(ops.removeLast());
        }
        ops.add(token);
      } else if (token == '(') {
        ops.add(token);
      } else if (token == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          output.add(ops.removeLast());
        }
        if (ops.isNotEmpty && ops.last == '(') ops.removeLast();
      }
    }

    while (ops.isNotEmpty) output.add(ops.removeLast());

    final stack = <double>[];
    for (var token in output) {
      if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(token)) {
        stack.add(double.parse(token));
      } else {
        final b = stack.removeLast();
        final a = stack.removeLast();
        double r;
        switch (token) {
          case '+':
            r = a + b;
            break;
          case '-':
            r = a - b;
            break;
          case '*':
            r = a * b;
            break;
          case '/':
            if (b == 0) throw Exception("Divide by zero");
            r = a / b;
            break;
          default:
            throw Exception("Invalid operator");
        }
        stack.add(r);
      }
    }
    return stack.single;
  }

  List<String> _tokenize(String exp) {
    exp = exp.replaceAll('×', '*').replaceAll('÷', '/');
    final tokens = <String>[];
    String num = '';
    for (int i = 0; i < exp.length; i++) {
      var c = exp[i];
      if ('0123456789.'.contains(c)) {
        num += c;
      } else {
        if (num.isNotEmpty) {
          tokens.add(num);
          num = '';
        }
        if ('+-*/()'.contains(c)) tokens.add(c);
      }
    }
    if (num.isNotEmpty) tokens.add(num);
    return tokens;
  }
}
