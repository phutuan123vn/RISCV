# addi gp,x0,0x06
# addi x4,x0,0x10
# addi x5,x0,0x4
# sll x30,x3,x4
# lui x30,0x45678
# srl x3,x30,x5
# sra x3,x30,x5
# addi gp,x0,0x06
# slli x30,x3,0x5
# addi x30,x30,0xfa
# srli x29,x3,0x3
# addi x3,x0,-20
# srai x28,x3,0x8
# addi x5,x0,0
# lui x30,0x12345
# addi gp,x0,0xf8
# add x29,x30,gp
# addi x30,x29,0xe3
# auipc x29,0x15600
# sh x29,8(x5)
# lw x20,8(x5)
# lh x20,8(x5)
# lb x20,8(x5)
# sw x30,8(x5)
# lb x8,8(x5)
# lh x9,8(x5)
# lbu x10,8(x5)
# lhu x11,8(x5)
# batdau:
# addi sp,zero,0x04
# add t0,gp,sp
# addi x5,x0,0x30
# addi x4,x0,0
# sw x5,8(x4)
# lw x25,8(x4)
# add x9,x12,x3
# addi x1,x0,0x678
# lui x1,0x12345
# add x20,x1,x0
# blt x5,x9,batdau
# addi x3,x0,0x0a
# 

main: 
addi x2,x0,5 #x2 = 5 
addi x3,x0,12 #x3 = 12 
addi x7,x3,-9 #x7 = (12 - 9) = 3 
or x4,x7,x2 #x4 = (3 OR 5) = 7 
and x5,x3,x4 #x5 = (12 AND 7) = 4 
add x5,x5,x4 #x5 = 4 + 7 = 11 
beq x5,x7,end #shouldn't be taken 
slt x4,x3,x4 #x4 = (12 < 7) = 0 
beq x4,x0,around #should be taken 
addi x5,x0,0 #shouldn't execute 
around: 
slt x4,x7,x2 #x4 = (3 < 5) = 1 
add x7,x4,x5 #x7 = (1 + 11) = 12 
sub x7,x7,x2 #x7 = (12 - 5) = 7 
sw x7,84(x3) #[96] = 7 
lw x2,96(x0) #x2 = [96] = 7 
add x9,x2,x5 #x9 = (7 + 11) = 18 
jal x3,end #jump to end, x3 = 0x44 
addi x2,x0,1 #shouldn't execute 
end: 
add x2,x2,x9 #x2 = (7 + 18) = 25 
sw x2,0x20(x3) #[100] = 25 0221A023
done: beq x2,x2,done #infinite loop 