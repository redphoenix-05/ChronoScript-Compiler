// ChronoScript Calculator - Continuous Accumulator Mode
// Enter +  -  *  /  to operate on the running result
// Type  ac  or  stop  to quit

Energy apply(Energy acc, Stream op, Energy num) {
    Era (op == "+") {
        Resolve acc + num;
    }
    Alternate Era (op == "-") {
        Resolve acc - num;
    }
    Alternate Era (op == "*") {
        Resolve acc * num;
    }
    Alternate Era (op == "/") {
        Era (num == 0) {
            Broadcast("Error: Division by zero");
            Resolve acc;
        }
        Resolve acc / num;
    }
    Broadcast("Unknown operator. Use +  -  *  /");
    Resolve acc;
}

Event main() {
    Energy result;
    Stream op;
    Energy num;

    Broadcast("=== ChronoScript Calculator ===");
    Broadcast("Operators: +  -  *  /");
    Broadcast("Type  ac  or  stop  to quit");
    Broadcast("Enter starting number:");
    Observe(result);
    Broadcast(result);

    Loop (1) {
        Broadcast("Enter operator:");
        Observe(op);

        Era (op == "ac" || op == "stop") {
            Escape;
        }

        Broadcast("Enter number:");
        Observe(num);

        result = apply(result, op, num);
        Broadcast(result);
    }

    Broadcast("Calculator stopped.");
    Resolve 0;
}
