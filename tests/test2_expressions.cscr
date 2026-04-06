// Test 2: Arithmetic and Logical Expressions
// Tests: Binary operators, operator precedence, unary operators

Event main() {
    Matter a = 10;
    Matter b = 5;
    Energy x = 3.5;
    Energy y = 2.0;
    
    // Arithmetic expressions with precedence
    Matter result1 = a + b * 2;           // 10 + (5 * 2) = 20
    Matter result2 = (a + b) * 2;         // (10 + 5) * 2 = 30
    Matter result3 = a - b / 2;           // 10 - (5 / 2) = 8
    Matter result4 = a % b;               // 10 % 5 = 0
    
    // Power operator (exponentiation)
    Energy result5 = x ^ 2;               // 3.5 ^ 2 = 12.25
    
    // Unary operators
    Matter neg = -a;
    Matter pos = +b;
    Truth notTrue = !1;
    
    // Complex expressions with parentheses
    Energy complex = (x + y) * (x - y);
    Matter nested = ((a + b) * (a - b)) / 2;
    
    // Comparison operators
    Truth cmp1 = a > b;
    Truth cmp2 = a <= b;
    Truth cmp3 = a == b;
    Truth cmp4 = a != b;
    
    // Logical operators
    Truth logical1 = (a > b) && (x > y);
    Truth logical2 = (a < b) || (x < y);
    Truth logical3 = !(a == b);
    
    // Bitwise operators
    Matter bitAnd = a & b;
    Matter bitOr = a | b;
    Matter bitXor = a ^ b;
    Matter shiftLeft = a << 2;
    Matter shiftRight = a >> 1;
    
    // Compound assignments
    a = a + 5;
    b = b * 2;
    x = x - 1.5;
    
    Broadcast("Expressions test completed");
    Resolve 0;
}
