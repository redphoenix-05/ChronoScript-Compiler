// ChronoScript Calculator Program
// Demonstrates: functions, Observe (input), Broadcast, reforge/standard/perspective

Matter calculate(Matter a, Matter b, Matter op) {
    reforge (op) {
        standard 1: Resolve a + b;
        standard 2: Resolve a - b;
        standard 3: Resolve a * b;
        standard 4: {
            Era (b == 0) {
                Broadcast("Error: Division by zero");
                Resolve 0;
            }
            Resolve a / b;
        }
        standard 5: {
            Era (b == 0) {
                Broadcast("Error: Modulo by zero");
                Resolve 0;
            }
            Resolve a % b;
        }
        perspective: {
            Broadcast("Invalid operation code");
            Resolve 0;
        }
    }
    Resolve 0;
}

Event main() {
    Matter firstNumber;
    Matter secondNumber;
    Matter operation;

    Broadcast("ChronoScript Calculator");
    Broadcast("Operation: 1=Add  2=Subtract  3=Multiply  4=Divide  5=Modulo");

    Observe(firstNumber);
    Observe(secondNumber);
    Observe(operation);

    Matter result = calculate(firstNumber, secondNumber, operation);
    Broadcast(result);

    Resolve 0;
}
