// Test 4: Function Definitions and Calls
// Tests: Function declarations, parameters, return values, recursion

// Function with no parameters
Matter getDefaultValue() {
    Resolve 42;
}

// Function with single parameter
Matter square(Matter n) {
    Resolve n * n;
}

// Function with multiple parameters
Matter add(Matter a, Matter b) {
    Resolve a + b;
}

Energy multiply(Energy x, Energy y) {
    Resolve x * y;
}

// Recursive function: factorial
Matter factorial(Matter n) {
    Era (n <= 1) {
        Resolve 1;
    }
    Resolve n * factorial(n - 1);
}

// Recursive function: fibonacci
Matter fibonacci(Matter n) {
    Era (n <= 1) {
        Resolve n;
    }
    Resolve fibonacci(n - 1) + fibonacci(n - 2);
}

// Function with more complex logic
Matter maximum(Matter a, Matter b) {
    Era (a > b) {
        Resolve a;
    } Alternate {
        Resolve b;
    }
}

// Function that uses loops
Matter sumToN(Matter n) {
    Matter sum = 0;
    Loop (Matter i = 1; i <= n; i = i + 1) {
        sum = sum + i;
    }
    Resolve sum;
}

// Function with array parameter
Matter sumArray(Matter arr[], Matter size) {
    Matter total = 0;
    Loop (Matter i = 0; i < size; i = i + 1) {
        total = total + arr[i];
    }
    Resolve total;
}

// Void-like function (returns nothing meaningful)
Void printBanner() {
    Broadcast("=========================");
    Broadcast("ChronoScript Functions");
    Broadcast("=========================");
    Resolve;
}

// Main function demonstrating all function calls
Event main() {
    printBanner();
    
    // Simple function calls
    Matter def = getDefaultValue();
    Matter sq = square(7);
    Matter sum = add(15, 25);
    Energy prod = multiply(3.5, 2.0);
    
    // Nested function calls
    Matter result1 = add(square(3), square(4));  // 9 + 16 = 25
    Matter result2 = maximum(add(5, 10), add(8, 6));
    
    // Recursive function calls
    Matter fact5 = factorial(5);        // 120
    Matter fib7 = fibonacci(7);         // 13
    
    // Function with loop
    Matter sumTo10 = sumToN(10);        // 55
    
    // Array with function
    Matter numbers[5];
    numbers[0] = 1;
    numbers[1] = 2;
    numbers[2] = 3;
    numbers[3] = 4;
    numbers[4] = 5;
    Matter arraySum = sumArray(numbers, 5);  // 15
    
    // Using function results in expressions
    Matter combined = factorial(4) + fibonacci(6);
    
    // Function calls in conditions
    Era (maximum(10, 20) > 15) {
        Broadcast("Maximum is greater than 15");
    }
    
    Broadcast("Functions test completed");
    Resolve 0;
}
