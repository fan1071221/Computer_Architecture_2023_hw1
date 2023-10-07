#include <stdio.h>
#include <stdint.h>

typedef struct {
    uint32_t ip_prefix;
    uint8_t prefix_length;
    uint16_t leading_zeros;
} RouteEntry;

uint16_t count_leading_zeros(uint32_t value) {
    uint32_t x = value;
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);

    x -= ((x >> 1) & 0x55555555);
    x = ((x >> 2) & 0x33333333) + (x & 0x33333333);
    x = ((x >> 4) + x) & 0x0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);

    return (32 - (x & 0x3f));
}

int is_prefix_match(uint32_t target_ip, uint32_t prefix, uint8_t prefix_length) {
    uint32_t mask = ~((1 << (32 - prefix_length)) - 1);
    return (target_ip & mask) == prefix;
}

void find_best_match(uint32_t target_ip, RouteEntry* routes, int num_routes) {
    int best_match_index = -1;
    uint16_t max_leading_zeros = 0;

    printf("Target IP: %u.%u.%u.%u\n", 
           (target_ip >> 24) & 0xFF, (target_ip >> 16) & 0xFF, (target_ip >> 8) & 0xFF, target_ip & 0xFF);
    printf("CLZ values for each route:\n");
    for (int i = 0; i < num_routes; i++) {
        if (is_prefix_match(target_ip, routes[i].ip_prefix, routes[i].prefix_length)) {
            uint32_t xor_result = target_ip ^ routes[i].ip_prefix;
            routes[i].leading_zeros = count_leading_zeros(xor_result);
            printf("Route %u.%u.%u.%u/%u: CLZ = %u\n", 
                   (routes[i].ip_prefix >> 24) & 0xFF, (routes[i].ip_prefix >> 16) & 0xFF, 
                   (routes[i].ip_prefix >> 8) & 0xFF, routes[i].ip_prefix & 0xFF, 
                   routes[i].prefix_length, routes[i].leading_zeros);

            if (routes[i].leading_zeros > max_leading_zeros) {
                max_leading_zeros = routes[i].leading_zeros;
                best_match_index = i;
            }
        }
    }

    if (best_match_index != -1) {
        printf("Best matching route for IP %u.%u.%u.%u is: %u.%u.%u.%u/%u\n\n", 
               (target_ip >> 24) & 0xFF, (target_ip >> 16) & 0xFF, (target_ip >> 8) & 0xFF, target_ip & 0xFF,
               (routes[best_match_index].ip_prefix >> 24) & 0xFF, (routes[best_match_index].ip_prefix >> 16) & 0xFF, 
               (routes[best_match_index].ip_prefix >> 8) & 0xFF, routes[best_match_index].ip_prefix & 0xFF, 
               routes[best_match_index].prefix_length);
    } else {
        printf("No matching route found for IP %u.%u.%u.%u\n\n", 
               (target_ip >> 24) & 0xFF, (target_ip >> 16) & 0xFF, (target_ip >> 8) & 0xFF, target_ip & 0xFF);
    }
}

int main() {
    RouteEntry routes[] = {
        {0x0A000000, 8, 0},   // 10.0.0.0/8
        {0x0A010000, 16, 0},  // 10.1.0.0/16
        {0x0A010100, 24, 0},  // 10.1.1.0/24
        {0xC0A80000, 16, 0}   // 192.168.0.0/16
    };
    int num_routes = sizeof(routes) / sizeof(routes[0]);

    uint32_t ips[] = {
        0x0A010137,  // 10.1.1.55
        0x0A0000FF,  // 10.0.0.255
        0xC0A80001   // 192.168.0.1
    };
    int num_ips = sizeof(ips) / sizeof(ips[0]);

    for (int i = 0; i < num_ips; i++) {
        find_best_match(ips[i], routes, num_routes);
    }

    return 0;
}