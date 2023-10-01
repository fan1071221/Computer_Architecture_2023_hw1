.data
test_cases: 
    .word 2, 33, 16, 1
results: 
    .word 0, 0, 0, 0
string1: .string  "\nANS:"

.text
.globl main

main:
    la a0, string1
    li a7, 4
    ecall
    
    la a5, test_cases
    la a1, results
    li a2, 4
    
loop:
    beqz a2, sort_loop_outer
    lw a3, 0(a5)
    mv a0, a3
    jal ra, count_leading_zeros
    sw a4, 0(a1)
    addi a5, a5, 4
    addi a1, a1, 4
    addi a2, a2, -1
    j loop
    
sort_loop_outer:
    li t4, 3
    
sort_loop_inner:
    la t0, results  # Use t0 to hold the address of the results array
    li t5, 0  # Initialize t5, the counter for the inner loop

inner_loop:
    bge t5, t4, outer_continue  # If t5 >= t4, jump to outer_continue
    lw a1, 0(t0)  # Load values using t0
    lw a2, 4(t0)  # Load the next value in the array
    ble a1, a2, inner_continue  # If the first value is less than or equal to the second, continue to the next pair
    
    sw a2, 0(t0)  # Swap values using t0
    sw a1, 4(t0)
    
inner_continue:
    addi t5, t5, 1  # Increment the counter for the inner loop
    addi t0, t0, 4  # Update t0 to point to the next element in results array
    j inner_loop  # Jump to the start of inner_loop
    
outer_continue:
    addi t4, t4, -1  # Decrement the counter for the outer loop
    bnez t4, sort_loop_inner  # If t4 is not zero, jump to the start of sort_loop_inner
    
print_results:
    la t0, results  # Load the address of results array to t0
    li a2, 4  # Set the counter a2 to 4
    
print_loop:
    beqz a2, exit  # If the counter a2 is zero, jump to exit
    lw a1, 0(t0)  # Load the value from results array to a1 using t0
    mv a0, a1  # Move the value from a1 to a0
    li a7, 1  # Set a7 to 1 for print integer syscall
    ecall  # Make syscall to print integer
    li a7, 11  # Set a7 to 11 for print character syscall
    li a0, 10  # Load ASCII value of newline (10) to a0
    ecall  # Make syscall to print newline character
    addi t0, t0, 4  # Update the address in t0 to point to the next element in results array
    addi a2, a2, -1  # Decrement the counter a2
    j print_loop  # Jump to the beginning of print_loop

exit:
    li a7, 10
    ecall

count_leading_zeros:
    li a4, 32
    beqz a3, clz_exit
    
    srli t1, a3, 1
    or a3, a3, t1
    srli t1, a3, 2
    or a3, a3, t1
    srli t1, a3, 4
    or a3, a3, t1
    srli t1, a3, 8
    or a3, a3, t1
    srli t1, a3, 16
    or a3, a3, t1
    
    li t1, 0x55555555
    srli t2, a3, 1
    and t2, t2, t1
    sub a3, a3, t2
    
    li t1, 0x33333333
    and t2, a3, t1
    srli t3, a3, 2
    and t3, t3, t1
    add a3, t2, t3
    
    li t1, 0x0f0f0f0f
    srli t2, a3, 4
    add t2, t2, a3
    and a3, t2, t1
    
    srli t1, a3, 8
    add a3, a3, t1
    srli t1, a3, 16
    add a3, a3, t1
    
    li t1, 0x7f
    and a3, a3, t1
    sub a4, a4, a3
    ret

clz_exit:
    ret
