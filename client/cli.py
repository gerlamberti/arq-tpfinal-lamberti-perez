import serial
import time
import binascii
from colorama import init, Fore, Style
from pprint import pprint
import assembler

def compile_instructions():
    # Aquí puedes agregar la lógica de compilación necesaria
    assembler.create_bin("ejemplo.asm", "entrada.bin")
    print("Compilando instrucciones...")

def compare_and_display(label, new_value, prev_value, color):
    if new_value != prev_value:
        if prev_value is None:
            prev_value = "None"
            prev_dec = "N/A"
        else:
            prev_dec = int(prev_value, 16)
        print(f"{color}{Style.BRIGHT}{label}: {new_value} (Hex) | {int(new_value, 16)} (Dec) * {Style.RESET_ALL}(Prev: {prev_value} (Hex) | {prev_dec} (Dec))")
    else:
        print(f"{color}{label}: {new_value} (Hex) | {int(new_value, 16)} (Dec)")

def main():
    # Inicializar colorama
    init(autoreset=True)
    
    # Solicitar puerto y baud rate al usuario, con valores por defecto
    port = input("Ingrese el puerto (por defecto: COM7): ") or "COM7"
    baud_rate = input("Ingrese el baud rate (por defecto: 9600): ")
    baud_rate = int(baud_rate) if baud_rate else 9600
    number_of_registers = 32
    number_of_memory_slots = 16

    prev_values = {
        'PC': None,
        'registros': [None] * number_of_registers,
        'ALU_RESULT': None,
        'memoria': [None] * number_of_memory_slots
    }

    try:
        # Configurar conexión UART
        ser = serial.Serial(port, baud_rate, timeout=1)
        print(f"Conectado a {port} con baud rate {baud_rate}")
    except serial.SerialException as e:
        print(f"No se pudo conectar al puerto {port}: {e}")
        return

    try:
        while True:
            # Leer entrada del usuario y enviar a UART
            user_input = input("Ingrese un comando para enviar: ").strip().lower()
            ser.reset_input_buffer() # Esto lo meto porque si la placa hace un reset se manda un byte no se por que

            if user_input == 'i':
                compile_instructions()  # Llamar a la función de compilación
                ser.write(b'i')  # Enviar la letra 'i' al módulo UART

                # Leer contenido del archivo y enviar
                file_path = input("Ingrese la ruta del archivo con instrucciones (por defecto entrada.bin):") or "entrada.bin"
                try:
                    with open(file_path, 'r') as file:
                        lines = file.readlines()
                        total_lines = len(lines)
                        bytes_sent = 0

                        ser.write(bytes(b'i'))  # Enviar la letra 'i' al módulo UART
                        ser.reset_output_buffer()
                        time.sleep(0.01)  # Ajustar el tiempo según sea necesario para la velocidad de UART
                        for line_number, line in enumerate(lines, start=1):
                            # Limpiar la línea y dividirla en bytes
                            line = line.strip()
                            if len(line) % 8 != 0:
                                print(f"La línea {line_number} no tiene un múltiplo de 8 bits. Se omite.")
                                continue
                            
                            for i in range(0, len(line), 8):
                                byte_str = line[i:i+8]
                                byte = int(byte_str, 2)  # Convertir binario a entero
                                
                                ser.write(bytes([byte]))  # Enviar el byte
                                pprint([byte])  # Enviar el byte
                                bytes_sent += 1

                            # Mostrar progreso
                            progress = (line_number / total_lines) * 100
                            print(f"Progreso: {progress:.2f}% ({bytes_sent} bytes enviados)")

                            time.sleep(0.01)  # Ajustar el tiempo según sea necesario para la velocidad de UART
                except FileNotFoundError:
                    print(f"No se pudo encontrar el archivo: {file_path}")
                    continue
                except Exception as e:
                    print(f"Error al leer el archivo: {e}")
                    continue

            else:
                ser.write(user_input.encode())

            # Leer respuesta de UART
            if user_input == 's' or user_input == 'c':
                # Leer y parsear los primeros 4 bytes como PC
                pc_data = ser.read(4)
                if len(pc_data) < 4:
                    print("Datos insuficientes para PC.")
                    continue
                pc_hex = binascii.hexlify(pc_data).decode()
                compare_and_display("PC", pc_hex, prev_values['PC'], Fore.GREEN)
                prev_values['PC'] = pc_hex

                # Leer y parsear 32 registros (128 bytes)
                for i in range(number_of_registers):
                    reg_data = ser.read(4)
                    if len(reg_data) < 4:
                        print(f"Datos insuficientes para el registro {i}.")
                        continue
                    reg_hex = binascii.hexlify(reg_data).decode()
                    compare_and_display(f"Registro {i}", reg_hex, prev_values['registros'][i], Fore.BLUE)
                    prev_values['registros'][i] = reg_hex

                # Leer y parsear ALU_RESULT (4 bytes)
                alu_result_data = ser.read(4)
                if len(alu_result_data) < 4:
                    print("Datos insuficientes para ALU_RESULT.")
                    continue
                alu_result_hex = binascii.hexlify(alu_result_data).decode()
                compare_and_display("ALU_RESULT", alu_result_hex, prev_values['ALU_RESULT'], Fore.RED)
                prev_values['ALU_RESULT'] = alu_result_hex

                # Leer y parsear MEMORY slots. 16 slots (4 bytes c/u)
                for i in range(number_of_memory_slots):
                    mem_data = ser.read(4)
                    if len(mem_data) < 4:
                        print(f"Datos insuficientes para el slot de memoria {i}.")
                        continue
                    mem_hex = binascii.hexlify(mem_data).decode()
                    memory_address = hex(i * 4)
                    compare_and_display(f"Memoria {memory_address}({i})", mem_hex, prev_values['memoria'][i], Fore.MAGENTA)
                    prev_values['memoria'][i] = mem_hex

    except KeyboardInterrupt:
        print("Terminando el programa.")
    finally:
        ser.close()

if __name__ == "__main__":
    main()
