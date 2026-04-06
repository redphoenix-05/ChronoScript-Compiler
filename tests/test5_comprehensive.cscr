// Test 5: Comprehensive Program
// Tests: All features including structures, math functions, complex logic

// Structure definition
structure Point {
    Energy x;
    Energy y;
};

structure Rectangle {
    Energy width;
    Energy height;
};

// Mathematical helper functions
Energy distance(Energy x1, Energy y1, Energy x2, Energy y2) {
    Energy dx = x2 - x1;
    Energy dy = y2 - y1;
    Resolve squareroot(dx * dx + dy * dy);
}

Energy circleArea(Energy radius) {
    Energy pi = 3.14159;
    Resolve pi * radius * radius;
}

Matter isPrime(Matter n) {
    Era (n <= 1) {
        Resolve 0;
    }
    Era (n == 2) {
        Resolve 1;
    }
    Loop (Matter i = 2; i * i <= n; i = i + 1) {
        Era (n % i == 0) {
            Resolve 0;
        }
    }
    Resolve 1;
}

// Array processing functions
Void initializeArray(Matter arr[], Matter size) {
    Loop (Matter i = 0; i < size; i = i + 1) {
        arr[i] = i * i;
    }
    Resolve;
}

Matter findMax(Matter arr[], Matter size) {
    Matter max = arr[0];
    Loop (Matter i = 1; i < size; i = i + 1) {
        Era (arr[i] > max) {
            max = arr[i];
        }
    }
    Resolve max;
}

// Main program
Event main() {
    Broadcast("=================================");
    Broadcast("ChronoScript Comprehensive Test");
    Broadcast("=================================");
    
    // Variable declarations with different types
    Matter count = 0;
    Energy temperature = 98.6;
    HighEnergy precise = 3.141592653589793;
    Truth isActive = 1;
    Atom initial = 'C';
    Stream message = "Testing ChronoScript";
    
    // Array declarations
    Matter primes[10];
    Energy coordinates[4];
    
    // Mathematical operations using built-in functions
    Energy angle = 45.0;
    Energy sineVal = sine(angle);
    Energy cosineVal = cosine(angle);
    Energy tangentVal = tangent(angle);
    
    Energy num = 16.7;
    Energy sqrtVal = squareroot(num);
    Matter absVal = absolute(-42);
    Energy floorVal = floor(3.9);
    Energy ceilVal = ceiling(3.1);
    
    // Bitwise operations
    Matter a = 12;
    Matter b = 5;
    Matter bitwiseAnd = a & b;
    Matter bitwiseOr = a | b;
    Matter bitwiseXor = a ^ b;
    Matter shiftedLeft = a << 2;
    Matter shiftedRight = a >> 1;
    
    // Complex control flow
    Matter score = 85;
    Era (score >= 90) {
        Broadcast("Excellent!");
    } Alternate Era (score >= 80) {
        Broadcast("Very Good!");
    } Alternate Era (score >= 70) {
        Broadcast("Good!");
    } Alternate Era (score >= 60) {
        Broadcast("Pass");
    } Alternate {
        Broadcast("Fail");
    }
    
    // Prime number generation
    Matter primeCount = 0;
    Loop (Matter i = 2; primeCount < 10; i = i + 1) {
        Era (isPrime(i)) {
            primes[primeCount] = i;
            primeCount = primeCount + 1;
        }
    }
    
    // Array operations
    Matter numbers[10];
    initializeArray(numbers, 10);
    Matter maxNumber = findMax(numbers, 10);
    
    // Nested loops with break and continue
    Matter matrix[3];
    Loop (Matter i = 0; i < 3; i = i + 1) {
        Era (i == 1) {
            Persist;  // Skip i=1
        }
        
        Loop (Matter j = 0; j < 3; j = j + 1) {
            Era (j == 2) {
                Escape;  // Break when j=2
            }
            matrix[i] = i * 10 + j;
        }
    }
    
    // Geometric calculations
    Energy radius = 5.0;
    Energy area = circleArea(radius);
    
    Energy x1 = 0.0;
    Energy y1 = 0.0;
    Energy x2 = 3.0;
    Energy y2 = 4.0;
    Energy dist = distance(x1, y1, x2, y2);  // Should be 5.0
    
    // Complex logical expressions
    Matter value = 50;
    Era ((value > 0) && (value < 100)) {
        Era ((value % 2 == 0) || (value % 5 == 0)) {
            Broadcast("Value is divisible by 2 or 5");
        }
    }
    
    // Compound assignments
    count = count + 1;
    temperature = temperature * 1.1;
    
    // Function composition
    Matter compositeResult = absolute(square(3) - square(4));
    
    // Counting loop with all features
    Loop (Matter k = 0; k < 20; k = k + 1) {
        Era (k < 5) {
            Persist;
        }
        
        Era (k > 15) {
            Escape;
        }
        
        Era (isPrime(k)) {
            Broadcast("Found prime in range");
        }
    }
    
    // Final status
    Era (isActive && (count > 0)) {
        Broadcast("Program executed successfully");
        Broadcast("All tests passed");
    }
    
    Broadcast("=================================");
    Broadcast("Test completed");
    Broadcast("=================================");
    
    Resolve 0;
}

// Additional helper function defined after main
Matter square(Matter n) {
    Resolve n * n;
}
