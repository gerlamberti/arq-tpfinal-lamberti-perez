`timescale 1ns / 1ps

module stall_unit #(
    REGS = 5
) (
    input [REGS-1:0] i_ID_EX_rt,
    input [REGS-1:0] i_IF_ID_rt,
    input [REGS-1:0] i_IF_ID_rs,
    input            i_ID_EX_mem_read,
    input            i_branch_taken,
    input            i_EX_jump_or_jalr,
    input            i_MEM_jump_or_jalr,
    input            i_MEM_halt,
    input            i_WB_halt,

    output reg o_flush_IF_ID,
    output reg o_flush_ID,
    output reg o_flush_EX_MEM,
    output reg o_stall_IF_ID,
    output reg o_stall_pc  // Previene que se incremente
);
  always @(*) begin
    if (i_branch_taken) begin  // Hazards con branches
      // Flush all
      o_flush_IF_ID  = 1'b1;
      o_flush_EX_MEM = 1'b1;
      o_flush_ID     = 1'b1;  // DECODE
      o_stall_IF_ID  = 1'b0;
      o_stall_pc     = 1'b0;
    end else if (i_EX_jump_or_jalr || i_MEM_jump_or_jalr) begin  // Hazards con jumps
      // Al tomar el salto se borra las dos instrucciones que entran despues del salto porque son instrucciones invalidas
      // No hay stall
      o_flush_IF_ID  = 1'b0;
      o_flush_EX_MEM = 1'b0;
      o_flush_ID     = 1'b1;
      o_stall_IF_ID  = 1'b0;
      o_stall_pc     = 1'b0;
    end else if (i_MEM_halt || i_WB_halt) begin  // halt
      // Flush all
      // Cuando el HALT llega a las ultimas dos etapas se vacian las etapas anteriores
      o_flush_IF_ID  = 1'b1;
      o_flush_EX_MEM = 1'b1;
      o_flush_ID     = 1'b1;
      o_stall_IF_ID  = 1'b0;
      o_stall_pc     = 1'b1;
    end else begin
      // data hazards (LOAD)
      // LW $2 , 4($0)
      // ADD $4 , $2 , $3
      if (((i_ID_EX_rt == i_IF_ID_rt) || (i_ID_EX_rt == i_IF_ID_rs)) && i_ID_EX_mem_read) begin
        o_flush_IF_ID  = 1'b0;  // No hay flush en FETCH
        o_flush_EX_MEM = 1'b0;  // No hay flush en EXECUTE


        // Si meto burbuja en ID luego los registros que siguen propagan la burbuja
        o_flush_ID     = 1'b1;
        // Necesito deshabilitar este reg intermedio para que en el siguiente clock
        // Siga valiento lo mismo que antes.
        o_stall_IF_ID  = 1'b1;
        // Tambien necesito deshabilitar el PC para que recien se actualice en el
        // siguiente ciclo
        o_stall_pc     = 1'b1;  // disable PC
      end else begin
        o_flush_IF_ID  = 1'b0;  // No hay flush en FETCH
        o_flush_EX_MEM = 1'b0;  // No hay flush en EXECUTE
        o_flush_ID     = 1'b0;
        o_stall_IF_ID  = 1'b0;
        o_stall_pc     = 1'b0;
      end
    end
  end
endmodule
