// -----------------------------------------------------------------------------
// 'dvbs2_tx_wrapper_regmap' Register Component
// Revision: 41
// -----------------------------------------------------------------------------
// Generated on 2021-03-16 at 19:31 (UTC) by airhdl version 2021.03.1
// -----------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

`default_nettype none

module dvbs2_tx_wrapper_regmap_regs #(
    parameter AXI_ADDR_WIDTH = 32, // width of the AXI address bus
    parameter logic [31:0] BASEADDR = 32'h00000000 // the register file's system base address 
    ) (
    // Clock and Reset
    input  wire                      axi_aclk,
    input  wire                      axi_aresetn,
                                     
    // AXI Write Address Channel     
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [2:0]                s_axi_awprot,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,
                                     
    // AXI Write Data Channel        
    input  wire [31:0]               s_axi_wdata,
    input  wire [3:0]                s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,
                                     
    // AXI Read Address Channel      
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [2:0]                s_axi_arprot,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,
                                     
    // AXI Read Data Channel         
    output wire [31:0]               s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,
                                     
    // AXI Write Response Channel    
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,
    
    // User Ports
    input dvbs2_tx_wrapper_regmap_regs_pkg::user2regs_t user2regs,
    output dvbs2_tx_wrapper_regmap_regs_pkg::regs2user_t regs2user
    );

    // Constants
    localparam logic [1:0]                      AXI_OKAY        = 2'b00;
    localparam logic [1:0]                      AXI_DECERR      = 2'b11;

    // Registered signals
    logic                                       s_axi_awready_r;
    logic                                       s_axi_wready_r;
    logic [$bits(s_axi_awaddr)-1:0]             s_axi_awaddr_reg_r;
    logic                                       s_axi_bvalid_r;
    logic [$bits(s_axi_bresp)-1:0]              s_axi_bresp_r;
    logic                                       s_axi_arready_r;
    logic [$bits(s_axi_araddr)-1:0]             s_axi_araddr_reg_r;
    logic                                       s_axi_rvalid_r;
    logic [$bits(s_axi_rresp)-1:0]              s_axi_rresp_r;
    logic [$bits(s_axi_wdata)-1:0]              s_axi_wdata_reg_r;
    logic [$bits(s_axi_wstrb)-1:0]              s_axi_wstrb_reg_r;
    logic [$bits(s_axi_rdata)-1:0]              s_axi_rdata_r;

    // User-defined registers
    logic s_config_strobe_r;
    logic [0:0] s_reg_config_enable_dummy_frames_r;
    logic s_ldpc_fifo_status_strobe_r;
    logic [13:0] s_reg_ldpc_fifo_status_ldpc_fifo_entries;
    logic [0:0] s_reg_ldpc_fifo_status_ldpc_fifo_empty;
    logic [0:0] s_reg_ldpc_fifo_status_ldpc_fifo_full;
    logic s_frames_in_transit_strobe_r;
    logic [7:0] s_reg_frames_in_transit_value;
    logic [7:0] s_bit_mapper_ram_raddr_r;
    logic [31:0] s_bit_mapper_ram_rdata;
    logic [7:0] s_bit_mapper_ram_waddr_r;
    logic [3:0] s_bit_mapper_ram_wen_r;
    logic [31:0] s_bit_mapper_ram_wdata_r;        
    logic [8:0] s_polyphase_filter_coefficients_waddr_r;
    logic [3:0] s_polyphase_filter_coefficients_wen_r;
    logic [31:0] s_polyphase_filter_coefficients_wdata_r;        

    //--------------------------------------------------------------------------
    // Inputs
    //
    assign s_reg_ldpc_fifo_status_ldpc_fifo_entries = user2regs.ldpc_fifo_status_ldpc_fifo_entries;
    assign s_reg_ldpc_fifo_status_ldpc_fifo_empty = user2regs.ldpc_fifo_status_ldpc_fifo_empty;
    assign s_reg_ldpc_fifo_status_ldpc_fifo_full = user2regs.ldpc_fifo_status_ldpc_fifo_full;
    assign s_reg_frames_in_transit_value = user2regs.frames_in_transit_value;
    assign s_bit_mapper_ram_rdata = user2regs.bit_mapper_ram_rdata; 

    //--------------------------------------------------------------------------
    // Read-transaction FSM
    //    
    localparam MAX_MEMORY_LATENCY = 2;

    typedef enum {
        READ_IDLE,
        READ_REGISTER,
        WAIT_MEMORY_RDATA,
        READ_RESPONSE,
        READ_DONE
    } read_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: read_fsm
        // registered state variables
        read_state_t v_state_r;
        logic [31:0] v_rdata_r;
        logic [1:0] v_rresp_r;
        int v_mem_wait_count_r;
        // combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r          <= READ_IDLE;
            v_rdata_r          <= '0;
            v_rresp_r          <= '0;
            v_mem_wait_count_r <= 0;            
            s_axi_arready_r    <= '0;
            s_axi_rvalid_r     <= '0;
            s_axi_rresp_r      <= '0;
            s_axi_araddr_reg_r <= '0;
            s_axi_rdata_r      <= '0;
            s_ldpc_fifo_status_strobe_r <= '0;
            s_frames_in_transit_strobe_r <= '0;
            s_bit_mapper_ram_raddr_r <= '0;
        end else begin
            // Default values:
            s_axi_arready_r <= 1'b0;
            s_ldpc_fifo_status_strobe_r <= '0;
            s_frames_in_transit_strobe_r <= '0;
            s_bit_mapper_ram_raddr_r <= '0;

            case (v_state_r)

                // Wait for the start of a read transaction, which is 
                // initiated by the assertion of ARVALID
                READ_IDLE: begin
                    if (s_axi_arvalid) begin
                        s_axi_araddr_reg_r <= s_axi_araddr;     // save the read address
                        s_axi_arready_r    <= 1'b1;             // acknowledge the read-address
                        v_state_r          <= READ_REGISTER;
                    end
                end

                // Read from the actual storage element
                READ_REGISTER: begin
                    // defaults:
                    v_addr_hit = 1'b0;
                    v_rdata_r  <= '0;
                    
                    // register 'config' at address offset 0x0
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::CONFIG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_config_enable_dummy_frames_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'ldpc_fifo_status' at address offset 0x4
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::LDPC_FIFO_STATUS_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[13:0] <= s_reg_ldpc_fifo_status_ldpc_fifo_entries;
                        v_rdata_r[16:16] <= s_reg_ldpc_fifo_status_ldpc_fifo_empty;
                        v_rdata_r[17:17] <= s_reg_ldpc_fifo_status_ldpc_fifo_full;
                        s_ldpc_fifo_status_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'frames_in_transit' at address offset 0x8
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::FRAMES_IN_TRANSIT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[7:0] <= s_reg_frames_in_transit_value;
                        s_frames_in_transit_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // memory 'bit_mapper_ram' at address offset 0xC
                    if (s_axi_araddr_reg_r >= BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET && 
                        s_axi_araddr_reg_r < BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_DEPTH * 4) begin
                        v_addr_hit = 1'b1;
                        // generate memory read address:
                        v_mem_addr = s_axi_araddr_reg_r - BASEADDR - dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET;
                        s_bit_mapper_ram_raddr_r <= v_mem_addr[9:2]; // output address has 4-byte granularity
                        v_mem_wait_count_r <= dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_READ_LATENCY;
                        v_state_r <= WAIT_MEMORY_RDATA;
                    end
                    if (v_addr_hit) begin
                        v_rresp_r <= AXI_OKAY;
                    end else begin
                        v_rresp_r <= AXI_DECERR;
                        // pragma translate_off
                        $warning("ARADDR decode error");
                        // pragma translate_on
                        v_state_r <= READ_RESPONSE;
                    end
                end
                
                // Wait for memory read data
                WAIT_MEMORY_RDATA: begin
                    if (v_mem_wait_count_r == 0) begin
                        // memory 'bit_mapper_ram' at address offset 0xC
                        if (s_axi_araddr_reg_r >= BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET && 
                            s_axi_araddr_reg_r < BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_DEPTH * 4) begin
                            v_rdata_r[31:0] <= s_bit_mapper_ram_rdata[31:0];
                        end
                        v_state_r <= READ_RESPONSE;
                    end else begin
                        v_mem_wait_count_r <= v_mem_wait_count_r - 1;
                    end
                end

                // Generate read response
                READ_RESPONSE: begin
                    s_axi_rvalid_r <= 1'b1;
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    v_state_r      <= READ_DONE;
                end

                // Write transaction completed, wait for master RREADY to proceed
                READ_DONE: begin
                    if (s_axi_rready) begin
                        s_axi_rvalid_r <= 1'b0;
                        s_axi_rdata_r  <= '0;
                        v_state_r      <= READ_IDLE;
                    end
                end        
                                    
            endcase
        end
    end: read_fsm

    //--------------------------------------------------------------------------
    // Write-transaction FSM
    //    

    typedef enum {
        WRITE_IDLE,
        WRITE_ADDR_FIRST,
        WRITE_DATA_FIRST,
        WRITE_UPDATE_REGISTER,
        WRITE_DONE
    } write_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: write_fsm
        // registered state variables
        write_state_t v_state_r;
        // combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r                   <= WRITE_IDLE;
            s_axi_awready_r             <= 1'b0;
            s_axi_wready_r              <= 1'b0;
            s_axi_awaddr_reg_r          <= '0;
            s_axi_wdata_reg_r           <= '0;
            s_axi_wstrb_reg_r           <= '0;
            s_axi_bvalid_r              <= 1'b0;
            s_axi_bresp_r               <= '0;
                        
            s_config_strobe_r <= '0;
            s_reg_config_enable_dummy_frames_r <= dvbs2_tx_wrapper_regmap_regs_pkg::CONFIG_ENABLE_DUMMY_FRAMES_RESET;
            s_bit_mapper_ram_waddr_r <= '0;
            s_bit_mapper_ram_wen_r <= '0;
            s_bit_mapper_ram_wdata_r <= '0;
            s_polyphase_filter_coefficients_waddr_r <= '0;
            s_polyphase_filter_coefficients_wen_r <= '0;
            s_polyphase_filter_coefficients_wdata_r <= '0;

        end else begin
            // Default values:
            s_axi_awready_r <= 1'b0;
            s_axi_wready_r  <= 1'b0;
            s_config_strobe_r <= '0;
            s_bit_mapper_ram_waddr_r <= '0; // always reset to zero because of wired OR
            s_bit_mapper_ram_wen_r <= '0;
            s_polyphase_filter_coefficients_waddr_r <= '0; // always reset to zero because of wired OR
            s_polyphase_filter_coefficients_wen_r <= '0;
            v_addr_hit = 1'b0;

            case (v_state_r)

                // Wait for the start of a write transaction, which may be 
                // initiated by either of the following conditions:
                //   * assertion of both AWVALID and WVALID
                //   * assertion of AWVALID
                //   * assertion of WVALID
                WRITE_IDLE: begin
                    if (s_axi_awvalid && s_axi_wvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address 
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r     <= 1'b1; // acknowledge the write-data
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end else if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address 
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_ADDR_FIRST;
                    end else if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_DATA_FIRST;
                    end
                end

                // Address-first write transaction: wait for the write-data
                WRITE_ADDR_FIRST: begin
                    if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Data-first write transaction: wait for the write-address
                WRITE_DATA_FIRST: begin
                    if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address 
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Update the actual storage element
                WRITE_UPDATE_REGISTER: begin
                    s_axi_bresp_r  <= AXI_OKAY; // default value, may be overriden in case of decode error
                    s_axi_bvalid_r <= 1'b1;

                    // register 'config' at address offset 0x0
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::CONFIG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        s_config_strobe_r <= 1'b1;
                        // field 'enable_dummy_frames':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_enable_dummy_frames_r[0] <= s_axi_wdata_reg_r[0]; // enable_dummy_frames[0]
                        end
                    end



                    // memory 'bit_mapper_ram' at address offset 0xC                    
                    if (s_axi_awaddr_reg_r >= BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET && 
                        s_axi_awaddr_reg_r < BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET + dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_DEPTH * 4) begin
                        v_addr_hit = 1'b1;
                        v_mem_addr = s_axi_awaddr_reg_r - BASEADDR - dvbs2_tx_wrapper_regmap_regs_pkg::BIT_MAPPER_RAM_OFFSET;
                        s_bit_mapper_ram_waddr_r <= v_mem_addr[9:2]; // output address has 4-byte granularity
                        s_bit_mapper_ram_wen_r <= s_axi_wstrb_reg_r;
                        s_bit_mapper_ram_wdata_r <= s_axi_wdata_reg_r;
                    end    

                    // memory 'polyphase_filter_coefficients' at address offset 0x3CC                    
                    if (s_axi_awaddr_reg_r >= BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET && 
                        s_axi_awaddr_reg_r < BASEADDR + dvbs2_tx_wrapper_regmap_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET + dvbs2_tx_wrapper_regmap_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_DEPTH * 4) begin
                        v_addr_hit = 1'b1;
                        v_mem_addr = s_axi_awaddr_reg_r - BASEADDR - dvbs2_tx_wrapper_regmap_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET;
                        s_polyphase_filter_coefficients_waddr_r <= v_mem_addr[10:2]; // output address has 4-byte granularity
                        s_polyphase_filter_coefficients_wen_r <= s_axi_wstrb_reg_r;
                        s_polyphase_filter_coefficients_wdata_r <= s_axi_wdata_reg_r;
                    end    

                    if (!v_addr_hit) begin
                        s_axi_bresp_r   <= AXI_DECERR;
                        // pragma translate_off
                        $warning("AWADDR decode error");
                        // pragma translate_on
                    end
                    v_state_r <= WRITE_DONE;
                end

                // Write transaction completed, wait for master BREADY to proceed
                WRITE_DONE: begin
                    if (s_axi_bready) begin
                        s_axi_bvalid_r <= 1'b0;
                        v_state_r      <= WRITE_IDLE;
                    end
                end
            endcase


        end
    end: write_fsm

    //--------------------------------------------------------------------------
    // Outputs
    //
    assign s_axi_awready = s_axi_awready_r;
    assign s_axi_wready  = s_axi_wready_r;
    assign s_axi_bvalid  = s_axi_bvalid_r;
    assign s_axi_bresp   = s_axi_bresp_r;
    assign s_axi_arready = s_axi_arready_r;
    assign s_axi_rvalid  = s_axi_rvalid_r;
    assign s_axi_rresp   = s_axi_rresp_r;
    assign s_axi_rdata   = s_axi_rdata_r;

    assign regs2user.config_strobe = s_config_strobe_r;
    assign regs2user.config_enable_dummy_frames = s_reg_config_enable_dummy_frames_r;
    assign regs2user.ldpc_fifo_status_strobe = s_ldpc_fifo_status_strobe_r;
    assign regs2user.frames_in_transit_strobe = s_frames_in_transit_strobe_r;
    assign regs2user.bit_mapper_ram_addr = s_bit_mapper_ram_waddr_r | s_bit_mapper_ram_raddr_r; // using wired OR as read/write address multiplexer
    assign regs2user.bit_mapper_ram_wen = s_bit_mapper_ram_wen_r;   
    assign regs2user.bit_mapper_ram_wdata = s_bit_mapper_ram_wdata_r;
    assign regs2user.polyphase_filter_coefficients_addr = s_polyphase_filter_coefficients_waddr_r;     
    assign regs2user.polyphase_filter_coefficients_wen = s_polyphase_filter_coefficients_wen_r;   
    assign regs2user.polyphase_filter_coefficients_wdata = s_polyphase_filter_coefficients_wdata_r;

endmodule: dvbs2_tx_wrapper_regmap_regs

`resetall
