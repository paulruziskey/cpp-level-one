#include <cstdlib>
#include <iostream>
#include <string>

int main() {
    using std::cout, std::cin;

    cout << "Today's shipments:\n\n";
    cout << "| Truck Type | Cost | Net Wt. |\n";

    // Property of Kant C. Bugg.
    constexpr std::string test_shipment_type1 = "Dairy";
    constexpr unsigned short test_shipment_cost1 = 3'145'65;
    constexpr float test_shipment_net_wt1 = 12'338.546F;
    cout << "| " << test_shipment_type1 << " | " << test_shipment_cost1 << " | " << test_shipment_net_wt1 << " |\n";

    // Property of Kant B. Bugg.
    constexpr std::string test_shipment_type2{"Grocery"};
    constexpr unsigned long long test_shipment_cost2{9'983'47ULL};
    constexpr long double test_shipment_net_wt2{15'512.687L};
    cout << "| " << test_shipment_type2 << " | " << test_shipment_cost2 / 100 << " | " << test_shipment_net_wt2 << " |\n";

    // Property of Kant D. Bugg.
    double total_weight;
    int total_cost;
    int total_distance{}; // maybe adding brackets make a difference?
    std::string input, output; // why don't these have problems if `total_weight` does?
    cout << "Enter the shipment type: ";
    cin >> input;
    output += input + " shipment: ";
    cout << "Enter the shipment origin: ";
    cin >> input; // why does this get skipped sometimes?
    output += input + " -> ";
    cout << "Enter the shipment destination: ";
    cin >> input;
    output += input;
    cout << "Enter the total cost for the shipment: ";
    cin >> total_cost; // why do the cents end up in the total weight?
    cout << "Enter the total weight for the shipment: ";
    cin >> total_weight; // why does this get skipped sometimes?
    cout << "Enter the shipment distance: ";
    cin >> total_distance; // why does this get skipped sometimes?
    // What's up with the wacky output for `total_weight` when the input doesn't work? Does this happen for you?
    cout << "\n" << output << "\n$" << total_cost << " | " << total_weight << "lbs. | " << total_distance << "mi.\n";

    return EXIT_SUCCESS;
}
