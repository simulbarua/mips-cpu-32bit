main:  addi $a0, $0, 5      # initialize $a0=5(n)
       sw   $a0, 0($0)      # [0x00] = 5 (n)
       addi $s0, $0, 1      # initialize $s0=1 (f)
       addi $t0, $0, 1      # initialize $t0=1
while: slt  $t1, $t0, $a0   # $t1 = 1 < n = 1
       beq  $t1, $0, end    # $t1 == 0 ? end : while
       mult $s0, $a0        # f*n
       mflo $s0             # $s0(f)=mflo
       addi $a0, $a0, -1    # $a0(n) = $a0(n) - 1
       j while              # Go back to while
end:   sw $s0, 0x10($0)     # [0x10] = n!