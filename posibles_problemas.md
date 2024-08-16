# Problemas por el que no anda el modo continuo

Tenemos detectado lo siguiente
- En step by step sí anda bien, osea ejecuta correcamente
- Si le damos un c se clava entre los loops que tenemos.


Posibles problemas:
- En modo continuo los registros no se escriben correctamente
- En modo continuo los ADDs no se ejecutan
    - Verificamos en las simulaciones que esto es así.
- Creemos que no es un problema de timing, porque cuando probamos el behavioural pasa exactamente lo mismo que pasa en la placa.

Camino a seguir:
1. Buscar un programa bien bien corto en el que suceda este problema. Tiene que tener un loop este programa
2. Simularlo y verificar en behavioural por qué sucede este tema

Opción 2:
1. Cambiar la debug unit para que en el modo continuo mande un "step", frene, "step", frene. Y verificar si con eso anda el modo continuo

Opcion 3:
Correr el mismo programa, pero desactivando los flushes y burbujas. Y en cambio, poner nops para que no haya riesgos de datos/control





## El programa que tiene que andar, original, es este:

´´´asm
nop
# PC = 4
addi $1,$0,12 # Load value 12 into $1
# PC = 8
sw $1,4($0) # Store $1 at memory address 4
# PC = 12
addi $1,$0,124 # Load value 124 into $1
# PC = 16
sw $1,8($0) # Store $1 at memory address 8
# PC = 20
addi $1,$0,45 # Load value 45 into $1
# PC = 24
sw $1,12($0) # Store $1 at memory address 12
# PC = 28
addi $1,$0,4124 # Load value 4124 into $1
# PC = 32
sw $1,16($0) # Store $1 at memory address 16
# PC = 36
addi $1,$0,41 # Load value 41 into $1

# PC = 40
sw $1,20($0) # Store $1 at memory address 20
# PC = 44
addi $1,$0,23 # Load value 23 into $1
# PC = 48
sw $1,24($0) # Store $1 at memory address 24
# PC = 52
addi $1,$0,165 # Load value 165 into $1
# PC = 56
sw $1,28($0) # Store $1 at memory address 28
# PC = 60
addi $10,$0,0 # max_value = 0
# PC = 64
addi $11,$0,4 # initial_address = 4
# PC = 68
addi $12,$0,32 # end_address = 28 + 4 
# PC = 72
lw $1,0($11) # Load $1 <- memory[initial_address]
# PC = 76
slt $2,$10,$1 # $10(max) < $1(current) ? $2 = 1 : $2 = 0
# PC = 80
beq $2,$0,2 # If $2 == 0, $10 >= $1, skip to increment
nop
add $10,$1,$0 # $10 (max_value) <- $1 (current_value)
addi $11,$11,4 # increment index
slt $2,$11,$12 # $11(inital_address) < $12(end_address) ? $2 = 1 : $2 = 0
bne $2,$0,65528 # If initial_address != end_address, loop back
nop
halt

´´´