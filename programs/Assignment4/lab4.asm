# $a0 = array base address
# $a1 = n
# $s0 = n!

Main:
    addi $a0, $0, 0x100     # array base address = 0x100
    addi $a1, $0, 0         # i = 0
    addi $t0, $0, 3
    addi $t1, $0, 50        # $t1 = 50

CreateArray_Loop:
    slt $t2, $a1, $t1       # i < 50?
    beq $t2, $0, Exit_Loop  # if not then exit loop
    sll $t2, $a1, 2         # $t2 = i * 4 (byte offset)
    add $t2, $t2, $a0       # address of array[i]
    mult $a1, $t0
    mflo $t3                # $t3 = i * 3
    sw $t3, 0($t2)          # save array[i]
    addi $a1, $a1, 1        # i = i + 1
    j CreateArray_Loop

Exit_Loop:
    # your code goes in here...
    # arithmetic calculation
    lw $t0, 100($a0)        # $t0 = array[25]
    lw $t1, 120($a0)        # $t1 = array[30]
    add $a1, $t0, $t1       # $a1 = my_array[25] + my_array[30]
    addi $t2, $0, 30        # $t2 = 30
    div $a1, $t2            # (my_array[25] + my_array[30])/30
    mflo $a1                # $a1(n)= mflo
    sw $a1, 0($0)           # [0] = n
    
    # factorial computation
    jal factorial           # call procedure
    add $s0, $v0, $0        # return value
    j end                   # jump to end on finish

factorial:
    addi $sp, $sp, -8       # make room on the stack
    sw $a1, 4($sp)          # store $a1 (n)
    sw $ra, 0($sp)          # store $ra
    # your code goes in here
    slti $t0, $a1, 2        # n <= 1 ? 1 : 0
    beq $t0, $0, else       # if n > 1, jump to else
    addi $v0, $0, 1         # return 1
    addi $sp, $sp, 8        # restore stack
    jr $ra                  # return
else:
    addi $a1, $a1, -1       # n = n-1
    jal factorial           # recursive call to factorial
    lw $ra, 0($sp)          # restore return address
    lw $a1, 4($sp)          # restore n
    addi $sp, $sp, 8        # restore stack
    mult $a1, $v0           # n * factorial(n-1)
    mflo $v0                # n!
    jr $ra                  # return
end:
    sw $s0, 0x10($0)        # [10] = n!