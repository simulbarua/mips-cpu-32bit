#       Assembly                 Description
main:  ori  $a0, $0, 0x8000      # a = 0x8000
       ori  $a1, $0, 0x00A9      # b = 0x00A9
       addi $s0, $0, 1974        # c = 1974
       mult $a0, $a0             # a*a
       mflo $s1                  # x = a*a          
       sw   $s1, 0x20($0)        # [0x20] = x 
       mult $s1, $a1             # y = x*b 
       mflo $s2                  # y lower 32 bits
       mfhi $s3                  # y upper 32 bit
       sw   $s2, 0x24($0)        # [0x24] = y (lower 32 bits)
       sw   $s3, 0x28($0)        # [0x28] = y (upper 32 bits)
       srl  $s2, $s2, 16                    
       sll  $t0, $s3, 16         
       or   $s2, $t0, $s2        # y = y >> 16                    
       div  $s2, $s0             # y/c
       mflo $t1                  # save quotient
       add  $s0, $s0, $t1        # c = c + y/c
       srl  $s0, $s0, 1          # c = c/2
       sw   $s0, 0x2C($0)        # [0x2C] = c
while: slti $t2, $s0, 1665       # check if c<1665
       bne  $t2, $0, end         # exit while loop for c<1665
       div  $s2, $s0             # y/c
       mflo $t1                  # save quotient
       add  $s0, $s0, $t1        # c = c + y/c
       srl  $s0, $s0, 1          # c = c/2
       j    while                # loop back to while
end:   sll  $s0, $s0, 8          # c = c << 8
       sw   $s0, 0x30($0)        # [0x30] = c