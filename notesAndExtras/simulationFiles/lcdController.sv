
// Controller FSM States
typedef enum logic [4:0] {
        wait_SPI,
        clear_display,
        cursor_home,
        write_letter, write_number} 
  lcd_controller_statetype;

module lcdController(
    input   logic   reset,
    input   logic   clk,
    input   logic   new_SPI,
    input   logic   [7:0]   letter,
    input   logic   [7:0]   number,
    output  logic   [7:0]   d,
    output  logic   e,
    output  logic   rs,
	output  logic   busy_flag,
    output  lcd_fsm_statetype   state_fsm,
    output  lcd_controller_statetype    state_con,
    output  logic   flag_check
    );

    // Create internal logic
    logic [7:0] d_in;
    logic rs_in;
    logic waiting;
    logic data_ready;
	logic [7:0] letter_reg, number_reg;
    logic [4:0] cont_count;
    logic cycle5;
    lcd_controller_statetype nextstate_con; //state_con is defined as an output

    // Call to create the lowest level control FSM
    lcdFSM lcdfsmCall(reset, clk, data_ready, d_in, rs_in, d, e, rs, busy_flag, state_fsm,flag_check);

    ////////////////////////  Registers  ////////////////////////////
    always_ff @(posedge clk) begin
        // state_con Registers
        if (reset)      // If Not Reset... (active low reset)
            state_con <= nextstate_con;
        else            // Else, if reset...
            state_con <= wait_SPI;

        // Letter/Number Registers
        if (~reset) begin      // If Reset...  (active low reset)
            letter_reg <= 8'h00;
            number_reg <= 8'h00; end
        else if ( (new_SPI) && (waiting) ) begin // If new_SPI just went high, store new
            letter_reg <= letter;
            number_reg <= number; end
        else begin                              // Otherwise, retain old values
            letter_reg <= letter_reg;
            number_reg <= number_reg; end

        if (state_con !== nextstate_con) begin
            cont_count <= 0;
            cycle5 <= 0; end
        else if (cont_count==5)
            cycle5 <= 1;
        else
            cont_count <= cont_count + 1;
        
    end
    
    /* I NEED TO ACCOUNT FOR CYCLES OF DELAY!!! */

    /* I NEED TO ACCOUNT FOR PUTTING DATA_READY FLAG HIGH SO FSM STARTS */

    ////////////////////////  Next state_con Logic  /////////////////////
    always_comb
        case (state_con)
            wait_SPI:       if (new_SPI)    nextstate_con = clear_display;     
                            else            nextstate_con = wait_SPI;
            clear_display:  if ((!busy_flag) & (cycle5)) nextstate_con = cursor_home;
                            else            nextstate_con = clear_display;
            cursor_home:    if ((!busy_flag) & (cycle5)) nextstate_con = write_letter;
                            else            nextstate_con = cursor_home;
            write_letter:   if ((!busy_flag) & (cycle5)) nextstate_con = write_number;
                            else            nextstate_con = write_letter;
            write_number:   if ((!busy_flag) & (cycle5)) nextstate_con = wait_SPI;
                            else            nextstate_con = write_number;
            default: nextstate_con = wait_SPI;
        endcase

    ////////////////////////  Output Logic  /////////////////////
    always_comb
        case (state_con)
            wait_SPI:       begin rs_in=0; waiting=1; d_in=8'h00; data_ready=0; end
            clear_display:  begin rs_in=0; waiting=0; d_in=8'h01; data_ready=1; end
            cursor_home:    begin rs_in=0; waiting=0; d_in=8'h02; data_ready=1; end
            write_letter:   begin rs_in=1; waiting=0; d_in=letter_reg; data_ready=1; end
            write_number:   begin rs_in=1; waiting=0; d_in=number_reg; data_ready=1; end
            default:    begin rs_in=0; waiting=1; d_in=8'h00; data_ready=0; end
        endcase


endmodule