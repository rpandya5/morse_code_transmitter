module part3(
    input wire CLOCK_50,
    input wire [2:0] SW,
    input wire [1:0] KEY,
    output wire [0:0] LEDR0
);

    wire reset;
    wire start;
    wire current_symbol;
    wire length_done;
    wire half_sec_tick;
    wire load_regs;
    wire shift_symbol;
    wire counter_enable;

    wire [3:0] morse_pattern;
    wire [2:0] pattern_length;

    // active-low to active-high
    assign reset = ~KEY[0];
    assign start = ~KEY[1];

    // letter selection logic
    letter_selection_logic letter_logic(
        .letter_select(SW),
        .morse_pattern(morse_pattern),
        .pattern_length(pattern_length)
    );

    // morse shift register
    morse_shift_register shift_reg(
        .clock(CLOCK_50),
        .reset(reset),
        .load(load_regs),
        .shift(shift_symbol),
        .letter_select(SW),
        .current_symbol(current_symbol)
    );

    // morse length counter
    morse_length_counter length_counter(
        .clock(CLOCK_50),
        .reset(reset),
        .enable(shift_symbol),
        .load(load_regs),
        .letter_select(SW),
        .done(length_done),
        .count()
    );

    // half second counter
    half_second_counter half_sec_counter(
        .clock_50(CLOCK_50),
        .reset(reset),
        .enable(counter_enable),
        .half_sec_tick(half_sec_tick)
    );

    // FSM controller
    morse_fsm controller(
        .clock(CLOCK_50),
        .reset(reset),
        .start(start),
        .letter(SW),
        .current_symbol(current_symbol),
        .length_done(length_done),
        .half_sec_tick(half_sec_tick),
        .led(LEDR[0]),
        .load_regs(load_regs),
        .shift_symbol(shift_symbol),
        .counter_enable(counter_enable)
    );

endmodule

module letter_selection_logic(
    input wire [2:0] letter_select,
    output reg [3:0] morse_pattern,
    output reg [2:0] pattern_length
);
    always @(*) begin // 0=dot, 1=dash
        case(letter_select)
            3'b000: begin  // A: .-
                morse_pattern = 4'b0100;
                pattern_length = 3'd2;
            end
            3'b001: begin  // B: -...
                morse_pattern = 4'b1000;
                pattern_length = 3'd4;
            end
            3'b010: begin  // C: -.-.
                morse_pattern = 4'b1010;
                pattern_length = 3'd4;
            end
            3'b011: begin  // D: -..
                morse_pattern = 4'b1000;
                pattern_length = 3'd3;
            end
            3'b100: begin  // E: .
                morse_pattern = 4'b0000;
                pattern_length = 3'd1;
            end
            3'b101: begin  // F: ..-.
                morse_pattern = 4'b0010;
                pattern_length = 3'd4;
            end
            3'b110: begin  // G: --.
                morse_pattern = 4'b1100;
                pattern_length = 3'd3;
            end
            3'b111: begin  // H: ....
                morse_pattern = 4'b0000;
                pattern_length = 3'd4;
            end
            default: begin
                morse_pattern = 4'b0000;
                pattern_length = 3'd0;
            end
        endcase
    end
endmodule

module morse_length_counter(
    input wire clock,
    input wire reset,
    input wire enable,
    input wire load,
    input wire [2:0] letter_select,
    output wire done,
    output reg [2:0] count
);
    reg [2:0] letter_length;
   
    always @(*) begin
        case(letter_select)
            3'b000: letter_length = 3'd2; // A: .-
            3'b001: letter_length = 3'd4; // B: -...
            3'b010: letter_length = 3'd4; // C: -.-.
            3'b011: letter_length = 3'd3; // D: -..
            3'b100: letter_length = 3'd1; // E: .
            3'b101: letter_length = 3'd4; // F: ..-.
            3'b110: letter_length = 3'd3; // G: --.
            3'b111: letter_length = 3'd4; // H: ....
            default: letter_length = 3'd0;
        endcase
    end

    assign done = (count == 3'd0);

    always @(posedge clock) begin
        if (reset) begin
            count <= 3'd0;
        end
        else if (load) begin
            count <= letter_length;
        end
        else if (enable && !done) begin
            count <= count - 3'd1;
        end
    end
endmodule

module morse_shift_register(
    input wire clock,
    input wire reset,
    input wire load,
    input wire shift,
    input wire [2:0] letter_select,
    output wire current_symbol
);
    reg [3:0] shift_reg;  // 4 bits for longest
    reg [3:0] morse_pattern;

    assign current_symbol = shift_reg[3];

    always @(*) begin
        case(letter_select)
            3'b000: morse_pattern = 4'b0100;    // A: .-
            3'b001: morse_pattern = 4'b1000;    // B: -...
            3'b010: morse_pattern = 4'b1010;    // C: -.-.
            3'b011: morse_pattern = 4'b1000;    // D: -..
            3'b100: morse_pattern = 4'b0000;    // E: .
            3'b101: morse_pattern = 4'b0010;    // F: ..-.
            3'b110: morse_pattern = 4'b1100;    // G: --.
            3'b111: morse_pattern = 4'b0000;    // H: ....
            default: morse_pattern = 4'b0000;
        endcase
    end

    always @(posedge clock) begin
        if (reset) begin
            shift_reg <= 4'b0;
        end
        else if (load) begin
            shift_reg <= morse_pattern;
        end
        else if (shift) begin
            shift_reg <= {shift_reg[2:0], 1'b0};
        end
    end
endmodule

module half_second_counter(
    input wire clock_50,
    input wire reset,
    input wire enable,
    output reg half_sec_tick
);
    localparam HALF_SEC = 25_000_000;
   
    reg [24:0] counter;
   
    always @(posedge clock_50) begin
        if (reset) begin
            counter <= 0;
            half_sec_tick <= 0;
        end
        else if (enable) begin
            if (counter == HALF_SEC - 1) begin
                counter <= 0;
                half_sec_tick <= 1;
            end
            else begin
                counter <= counter + 1;
                half_sec_tick <= 0;
            end
        end
        else begin
            counter <= counter;
            half_sec_tick <= 0;
        end
    end
endmodule

module morse_fsm (
    input wire clock,
    input wire reset,
    input wire start,
    input wire [2:0] letter,
    input wire current_symbol,
    input wire length_done,
    input wire half_sec_tick,
    output reg led,
    output reg load_regs,      // load shift reg and length counter
    output reg shift_symbol,   // shift to next symbol
    output reg counter_enable  // 0.5s counter
);

    // encodings encoding
    localparam  IDLE = 4'd0,
                LOAD = 4'd1,
                CHECK_SYMBOL = 4'd2,
                DOT = 4'd3,
                WAIT_DOT = 4'd4,
                DASH = 4'd5,
                WAIT_DASH1 = 4'd6,
                WAIT_DASH2 = 4'd7,
                WAIT_DASH3 = 4'd8,
                INTER_SYMBOL = 4'd9,
                CHECK_DONE = 4'd10;

    // state registers
    reg [3:0] current_state, next_state;

    // update
    always @(posedge clock) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // next state logic and outputs
    always @(*) begin
        next_state = current_state;
        led = 1'b0;
        load_regs = 1'b0;
        shift_symbol = 1'b0;
        counter_enable = 1'b0;

        case (current_state)
            IDLE: begin
                if (start)
                    next_state = LOAD;
            end

            LOAD: begin
                load_regs = 1'b1;
                next_state = CHECK_SYMBOL;
            end

            CHECK_SYMBOL: begin
                if (current_symbol == 0)
                    next_state = DOT;
                else
                    next_state = DASH;
            end

            DOT: begin
                led = 1'b1;
                counter_enable = 1'b1;
                next_state = WAIT_DOT;
            end

            WAIT_DOT: begin
                led = 1'b1;
                counter_enable = 1'b1;
                if (half_sec_tick)
                    next_state = INTER_SYMBOL;
            end

            DASH: begin
                led = 1'b1;
                counter_enable = 1'b1;
                next_state = WAIT_DASH1;
            end

            WAIT_DASH1: begin
                led = 1'b1;
                counter_enable = 1'b1;
                if (half_sec_tick)
                    next_state = WAIT_DASH2;
            end

            WAIT_DASH2: begin
                led = 1'b1;
                counter_enable = 1'b1;
                if (half_sec_tick)
                    next_state = WAIT_DASH3;
            end

            WAIT_DASH3: begin
                led = 1'b1;
                counter_enable = 1'b1;
                if (half_sec_tick)
                    next_state = INTER_SYMBOL;
            end

            INTER_SYMBOL: begin
                counter_enable = 1'b1;
                if (half_sec_tick) begin
                    shift_symbol = 1'b1;
                    next_state = CHECK_DONE;
                end
            end

            CHECK_DONE: begin
                if (length_done)
                    next_state = IDLE;
                else
                    next_state = CHECK_SYMBOL;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
