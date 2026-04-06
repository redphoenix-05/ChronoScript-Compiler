// Test 7: Unique ChronoScript Features
// Tests: SingularityCheck, MassAccumulation, Diverge, reforge/standard/perspective, Arrays

Event main() {
    // ---- SingularityCheck (prime detection) ----
    Era (SingularityCheck(17)) {
        Broadcast("17 is prime");
    }
    Era (SingularityCheck(4) == 0) {
        Broadcast("4 is not prime");
    }
    Era (SingularityCheck(2)) {
        Broadcast("2 is prime");
    }

    // ---- MassAccumulation (factorial) ----
    Matter fact5 = MassAccumulation(5);
    Era (fact5 == 120) {
        Broadcast("5! = 120");
    }
    Matter fact0 = MassAccumulation(0);
    Era (fact0 == 1) {
        Broadcast("0! = 1");
    }

    // ---- Diverge (while-loop alias) ----
    Matter x = 0;
    Diverge (x < 5) {
        x = x + 1;
    }
    Era (x == 5) {
        Broadcast("Diverge loop counted to 5");
    }

    // ---- reforge / standard / perspective (switch/case/default) ----
    Matter code = 2;
    reforge (code) {
        standard 1: Broadcast("one");
        standard 2: Broadcast("two");
        standard 3: Broadcast("three");
        perspective: Broadcast("other");
    }

    Matter unknownCode = 99;
    reforge (unknownCode) {
        standard 1: Broadcast("one");
        standard 2: Broadcast("two");
        perspective: Broadcast("default case hit");
    }

    // ---- Arrays ----
    Matter arr[5];
    arr[0] = 10;
    arr[1] = 20;
    arr[2] = 30;
    arr[3] = 40;
    arr[4] = 50;

    Matter total = 0;
    Loop (Matter i = 0; i < 5; i = i + 1) {
        total = total + arr[i];
    }
    Era (total == 150) {
        Broadcast("Array sum = 150");
    }

    Broadcast("All features verified");
    Resolve 0;
}
