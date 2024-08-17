nop # PC = 4
addi $7,$0,36 # PC = 8
addi $1,$0,4 # PC = 12
addi $2,$1,4 # PC = 16
jalr $7 # PC = 20  salta al 36 Chequear que $31 = 28
nop # PC = 24
addi $6,$0,2 # PC = 28
addi $7,$0,17 # PC = 32 No tiene que ejecutar
addi $8,$0,18 # PC = 36
addi $9,$0,29 # PC = 40
addi $10,$0,100 # PC = 44
addi $11,$0,212 # PC = 48
halt # PC = 44