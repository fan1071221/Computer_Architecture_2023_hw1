.data
routes:
    .word 0x0A000000, 8, 0
    .word 0x0A010000, 16, 0
    .word 0x0A010100, 24, 0
    .word 0xC0A80000, 16, 0

ips:
    .word 0x0A010137
    .word 0x0A0000FF
    .word 0xC0A80001

num_routes: .word 4
num_ips: .word 3
newline: .string "\n"
best_match_ip: .word 0
best_match_prefix: .word 0
dot: .string "."
slash: .string "/"
.text
.globl main

main:
    # Load base addresses of routes, ips, num_routes, and num_ips into registers
    la a1, routes
    la t1, ips
    la t0, num_routes
    lw a2, 0(t0)
    la t0, num_ips
    lw a3, 0(t0)

    # Loop through each IP and find the best match
ip_loop:
    beqz a3, exit        # If no more IPs, exit the loop

    lw a0, 0(t1)         # ips Load the current IP into a0
    #li a7, 1             # System call for print integer
    #ecall
    j find_best_match # Call the find_best_match function
    #addi t1, t1, 4       # Move to the next IP
    #addi a3, a3, -1      # Decrement the IP count
    #j ip_loop

exit:
    # Exit the program
    li a7, 10
    ecall

count_leading_zeros:
    li a4, 32
    srli s2, t2, 1
    or a6, t2, s2
    srli s2, a6, 2
    or a6, a6, s2
    srli s2, a6, 4
    or a6, a6, s2
    srli s2, a6, 8
    or a6, a6, s2
    srli s2, a6, 16
    or a6, a6, s2
    
    li s2, 0x55555555
    srli t2, a6, 1
    and t2, t2, s2
    sub a6, a6, t2
    
    li s2, 0x33333333
    and t2, a6, s2
    srli t3, a6, 2
    and t3, t3, s2
    add a6, t2, t3
    
    li s2, 0x0f0f0f0f
    srli t2, a6, 4
    add t2, t2, a6
    and a6, t2, s2
    
    srli s2, a6, 8
    add a6, a6, s2
    srli s2, a6, 16
    add a6, a6, s2
    
    li s2, 0x7f
    and a6, a6, s2
    sub a4, a4, a6
    ret
    
is_prefix_match:
    # a0: target_ip
    # a1: prefix
    # a4: prefix_length

    # Calculate the mask based on prefix_length
    li   t2, 32          # Load 32 into t2
    sub  t2, t2, a4      # Subtract prefix_length from 32
    li   t3, 1           # Load 1 into t3
    sll  t3, t3, t2      # Shift left 1 by the result of the subtraction
    addi t3, t3, -1      # Subtract 1 from the result to get a mask with leading zeros
    not  t2, t3          # Bitwise NOT to get the mask

    # Apply the mask to target_ip
    and  t2, a0, t2      # AND operation between target_ip and mask
    # Compare the result with prefix
    li   a5, 0           # Set return value to 0 (no match)
    beq  t2, t0, match   # If they are equal, it's a match
    ret

match:
    li   a5, 1           # Set return value to 1 (match)
    ret


find_best_match:
    # a0: target_ip
    # a1: base address of routes
    # a2: num_routes

    # Initialize best_match_index, max_leading_zeros, and route_index
    li t4, -1            # t4 will hold best_match_index
    li t5, 0             # t5 will hold max_leading_zeros
    li t6, 0             # t6 will hold route_index (number of routes traversed)
    li s3, 0             # s3 will hold best_match_ip
    li s4, 0             # s4 will hold best_match_prefix

loop_routes:
    beqz a2, end_loop    # If no more routes, end the loop
    # Load prefix and prefix_length from routes
    lw t0, 0(a1)         # t0 holds ip_prefix
    lbu a4, 4(a1)        # a3 holds prefix_length
    # Check if prefix matches
    jal ra, is_prefix_match
    beqz a5, skip_route  # If no match, skip to next route

    # Calculate leading zeros
    xor t2, a0, t0       # XOR target_ip and ip_prefix 
    jal ra, count_leading_zeros

    # Check if current route has more leading zeros than previous best
    blt t5, a4, update_best

    # If you reach here, it means the route matched but was not the best match
    # So, you can skip to the next route
    j skip_route
    
skip_route:
    addi a1, a1, 12       # Move to the next route entry
    addi a2, a2, -1      # Decrement num_routes
    addi t6, t6, 1       # Increment route_index
    j loop_routes

update_best:
    mv t5, a4            # Update max_leading_zeros
    mv t4, t6            # Update best_match_index with current route_index
    lw s3, 0(a1)         # Save the best match IP from routes
    lbu s4, 4(a1)        # Save the best match prefix from routes
    j skip_route

print_ip:
    # s3 contains the IP to be printed
    # Extract and print the first octet
    srli s5, s3, 24
    andi s5, s5, 0xFF
    mv a0, s5
    li a7, 1
    ecall

    # Print a dot
    la a0, dot
    li a7, 4
    ecall

    # Extract and print the second octet
    srli s5, s3, 16
    andi s5, s5, 0xFF
    mv a0, s5
    li a7, 1
    ecall

    # Print a dot
    la a0, dot
    li a7, 4
    ecall

    # Extract and print the third octet
    srli s5, s3, 8
    andi s5, s5, 0xFF
    mv a0, s5
    li a7, 1
    ecall

    # Print a dot
    la a0, dot
    li a7, 4
    ecall

    # Extract and print the fourth octet
    andi s5, s3, 0xFF
    mv a0, s5
    li a7, 1
    ecall

    ret


end_loop:
    # Print the best match IP
    mv a0, s3
    jal ra, print_ip
    la a0, slash
    li a7, 4
    ecall
    # Print the best match prefix
    mv a0, s4
    li a7, 1
    ecall
    la a0, newline
    li a7, 4
    ecall

    li a2, 4
    addi t1, t1, 4       # Move to the next IP
    addi a3, a3, -1      # Decrement the IP count
    la a1, routes
    j ip_loop