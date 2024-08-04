import time
from rich.progress import track

#Posicion en reg file
REGS = {
    '$0': '00000',
    '$1': '00001',
    '$2': '00010',
    '$3': '00011',
    '$4': '00100',
    '$5': '00101',
    '$6': '00110',
    '$7': '00111',
    '$8': '01000',
    '$9': '01001',
    '$10': '01010',
    '$11': '01011',
    '$12': '01100',
    '$13': '01101',
    '$14': '01110',
    '$15': '01111',
    '$16': '10000',
    '$17': '10001',
    '$18': '10010',
    '$19': '10011',
    '$20': '10100',
    '$21': '10101',
    '$22': '10110',
    '$23': '10111',
    '$24': '11000',
    '$25': '11001',
    '$26': '11010',
    '$27': '11011',
    '$28': '11100',
    '$29': '11101',
    '$30': '11110',
    '$31': '11111'
}
#table from: https://uweb.engr.arizona.edu/~ece369/Resources/spim/MIPSReference.pdf
#https://www.dsi.unive.it/~gasparetto/materials/MIPS_Instruction_Set.pdf

INSTRUCCIONES = {
    'add': ['r', '100000', 'null'],
    'addi': ['i', '001000', 'null'],
    'addu': ['r', '100001', 'null'],
    'sub': ['r', '100010', 'null'],
    'subu': ['r', '100011', 'null'],
    'nor': ['r', '100111', 'null'],
    'or': ['r', '100101', 'null'],
    'ori': ['i', '001101', 'null'],
    'and': ['r', '100100', 'null'],
    'andi': ['i', '001100', 'null'],
    'beq': ['i', '000100', 'branch'],
    'bne': ['i', '000101', 'branch'],
    'j': ['i', '000010', 'jump'],
    'jal': ['i', '000011', 'jump'],
    'jalr': ['j', '001001', 'null'],
    'jr': ['j', '001000', 'null'],
    'lb': ['i', '100000', 'offset'],
    'lbu': ['i', '100100', 'offset'],
    'lh': ['i', '100001', 'offset'],
    'lhu': ['i', '100101', 'offset'],
    'lui': ['i', '001111', 'lui'],
    'lw': ['i', '100011', 'offset'],
    'lwu': ['i', '100111', 'offset'],
    'sb': ['i', '101000', 'offset'],
    'sh': ['i', '101001', 'offset'],
    'sll': ['r', '000000', 'shift'],
    'sllv': ['r', '000100', 'shiftv'],
    'slt': ['r', '101010', 'null'],
    'slti': ['i', '001010', 'null'],
    'sra': ['r', '000011', 'shift'],
    'srav': ['r', '000111', 'shiftv'],
    'srl': ['r', '000010', 'shift'],
    'srlv': ['r', '000110', 'shiftv'],
    'sw': ['i', '101011', 'offset'],
    'xor': ['r', '100110', 'null'],
    'xori': ['i', '001110', 'null']
}

#Si es tipo r tengo shift,shiftv, arith
def tipo_r(instr, args):   
    opcode = INSTRUCCIONES[instr][1]
    syntax = INSTRUCCIONES[instr][2]
    if (syntax == 'shiftv'):
        rd, rt, rs = map(str.strip, args.split(','))
        rs = REGS[rs]
        rt = REGS[rt]
        rd = REGS[rd]
        instruc_bin = f"000000{rs}{rt}{rd}00000{opcode}"
    elif (syntax == 'shift'):
        rd, rt, shift = map(str.strip, args.split(','))
        rt = REGS[rt]
        rd = REGS[rd]
        shift = bin(int(shift) & 0b11111)[2:].zfill(5)
        instruc_bin = f"00000000000{rt}{rd}{shift}{opcode}"
    else:
        rd, rs, rt = map(str.strip, args.split(','))
        rs = REGS[rs]
        rt = REGS[rt]
        rd = REGS[rd]
        instruc_bin = f"000000{rs}{rt}{rd}00000{opcode}"
    return instruc_bin


def tipo_j(instr, args):
    opcode = INSTRUCCIONES[instr][1]
    if opcode == INSTRUCCIONES['jalr'][1]:
        rs = REGS[args]
        instruc_bin = f"000000{rs}000001111100000{opcode}"
    else:
        rs = REGS[args]
        instruc_bin = f"000000{rs}000000000000000{opcode}"
    return instruc_bin

def tipo_i(instr, args):
    opcode = INSTRUCCIONES[instr][1]
    syntax = INSTRUCCIONES[instr][2]   
    if (syntax == 'offset'):
        rt, iargs = map(str.strip, args.split(','))
        #obtengo el entero entre ()
        offset, reg_base = iargs.strip(')').split('(')
        base = REGS[reg_base]
        rt = REGS[rt]
        boffset = bin(int(offset) & 0b1111111111111111)[2:].zfill(16) #Se arma el binario y se elimina el '0b', me aseguro de llenar con 0 la izq
        instruc_bin = f"{opcode}{base}{rt}{boffset}"  
    elif (syntax == 'branch'):
        rs, rt, offset = map(str.strip, args.split(','))
        rs = REGS[rs]
        rt = REGS[rt]
        boffset = bin(int(offset) & 0b1111111111111111)[2:].zfill(16)
        instruc_bin = f"{opcode}{rs}{rt}{boffset}"  
    elif (syntax == 'jump'):
        btarget = bin(int(args) & 0b11111111111111111111111111)[2:].zfill(26) #convierte al numero entero a bin y lo multiplico con 1 para luego garantizar 26 bits
        instruc_bin = f"{opcode}{btarget}" #sumos los 6 de opcode
    elif (syntax == 'lui'):
        rt, immediate = map(str.strip, args.split(','))
        rt = REGS[rt]
        immediate = bin(int(immediate) & 0b1111111111111111)[2:].zfill(16)
        instruc_bin = f"{opcode}00000{rt}{immediate}"
    else:
        rt, rs, immediate = map(str.strip, args.split(','))
        rt = REGS[rt]
        rs = REGS[rs]
        immediate = bin(int(immediate) & 0b1111111111111111)[2:].zfill(16)
        instruc_bin = f"{opcode}{rs}{rt}{immediate}"
    return instruc_bin


def create_bin(asm_file, name_bin):
    count = 1
    with open(asm_file, 'r') as f:
        with open(name_bin, 'w') as out:
            for line in f:
                # Se obtiene el nombre de la instruc en la parte 0 y en la parte 1 los reg o datos
                parts = line.strip().split(' ')
                instruc_bin = 0
                if parts:
                    if (parts[0] == 'nop'):
                        instruc_bin = f"00000000000000000000000000000000"
                        out.write(instruc_bin + "\n")
                        count += 1
                    else:
                        #Identipo el tipo de instruccion
                        instr_type = INSTRUCCIONES[parts[0]][0]
                        #Armo el formato de la instruccion segun el tipo
                        if (instr_type == 'r'):
                            instruc_bin = tipo_r(parts[0], parts[1])

                        elif (instr_type == 'i'):
                            instruc_bin = tipo_i(parts[0], parts[1])

                        elif (instr_type == 'j'):
                            instruc_bin = tipo_j(parts[0], parts[1])

                        else:
                            print("##### tipo incorrecto #####")

                        out.write(instruc_bin + "\n")
                        count += 1
            #envio como unltima instruccion un HALT
            out.write(f"11111111111111111111111111111111")
    return count