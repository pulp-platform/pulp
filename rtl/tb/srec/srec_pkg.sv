// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Robert Balas (balasr@iis.ee.ethz.ch)

// Load srec dump and convert to stimuli and other format
package srec_pkg;
  localparam string SREC_START = "S";
  localparam byte   SREC_RECORD_TYPE_MASK = 'hf0;
  localparam byte   SREC_READ_STATE_MASK  = 'h0F;
  localparam int    SREC_LINE_MAX_BYTE_COUNT = 37;

  typedef enum {
    READ_WAIT_FOR_START = 0,
    READ_RECORD_TYPE,
    READ_GOT_RECORD_TYPE,   // dummy to make for alternating "high" and "low"
    READ_COUNT_HIGH,
    READ_COUNT_LOW,
    READ_DATA_HIGH,
    READ_DATA_LOW
  } srec_read_state_e;

  typedef enum {
    SREC_HEADER             = 0,    // header with ASCII data
    SREC_DATA_16BIT         = 1,    // payload with 16-bit address
    SREC_DATA_24BIT         = 2,    // payload with 24-bit address
    SREC_DATA_32BIT         = 3,    // payload with 32-bit address
    SREC_COUNT_16BIT        = 5,    // 16-bit count of payload records
    SREC_COUNT_24BIT        = 6,    // 24-bit count of payload records
    SREC_TERMINATION_32BIT  = 7,    // termination & 32-bit start address
    SREC_TERMINATION_24BIT  = 8,    // termination & 24-bit start address
    SREC_TERMINATION_16BIT  = 9     // termination & 16-bit start address
  } srec_record_number_e;

  typedef struct {
    srec_record_number_e rtype;
    logic [31:0]         addr;
    byte                 mem[SREC_LINE_MAX_BYTE_COUNT + 1];
    int                  length;
    byte                 checksum;
  } srec_record_t;

  typedef struct {
    byte flags;
    byte byte_count;
    byte length;
    byte data[SREC_LINE_MAX_BYTE_COUNT + 1];
    byte mem[SREC_LINE_MAX_BYTE_COUNT + 1];
  } srec_state_t;

  task automatic srec_read(string path, output srec_record_t records[$]);
    automatic int fd, err;
    automatic byte b;
    automatic string line;

    automatic srec_state_t srec;
    srec = '{default: 0};

    fd = $fopen(path, "r");
    if (!fd)
      $fatal(1, "srec_read: %s does not exist", path);

    while (!$feof(fd)) begin
      int err = $fgets(line, fd);
      // parse one srecord line
      for (int i = 0; i < line.len(); i++)
        srec_read_byte (srec, records, line[i]);
    end
    $fclose(fd);

  endtask // srec_read

  task automatic srec_read_byte(ref srec_state_t srec, ref srec_record_t records[$], input byte b);
    srec_record_t record;
    byte state = srec.flags & SREC_READ_STATE_MASK;
    srec.flags ^= state; // clear state
    if (b >= "0" && b  <= "9")
      b -= "0";
    else if (b >= "A" && b  <= "F")
      b -= "A" - 10;
    else if (b >= "a" && b <= "f")
      b -= "a" - 10;
    else if (b == "S") begin
      // sync to a new record at any state
      state = READ_RECORD_TYPE;
      srec_end_read(srec, record);
      //records.push_back(record);
      srec.flags |= state;
      return;
    end else begin
      // ignore unknown characters
      srec.flags |= state;
      return;
    end

    if (!(++state & 1)) begin
      // store high nybble temporarily
      b <<= 4;
      if (srec_read_state_e'(state) != READ_GOT_RECORD_TYPE) begin
        srec.data[srec.length] = b;
      end else begin
        ++state;
        srec.flags = b; // store type in upper nybble
      end
    end else begin
      // low nybble, combine with stored high nybble
      b = (srec.data[srec.length] |= b);
      case (state >> 1)
        (READ_COUNT_LOW >> 1): begin
          srec.byte_count = b;
          if (b > SREC_LINE_MAX_BYTE_COUNT) begin
            srec_end_read(srec, record);
            records.push_back(record);
            return;
          end
        end
        (READ_DATA_LOW >> 1): begin
          if (++srec.length < srec.byte_count) begin
            state = READ_DATA_HIGH;
          end else begin
            // end of srec line
            state = READ_WAIT_FOR_START;
            srec_end_read(srec, record);
            records.push_back(record);
          end
        end
        default: begin
          // wait for S
          return;
        end
      endcase // case (state >> 1)
    end

    srec.flags |= state;
  endtask // srec_read_byte

  task automatic srec_end_read(ref srec_state_t srec, output srec_record_t record);
    logic [31:0] addr = 0;
    byte record_type = (srec.flags & SREC_RECORD_TYPE_MASK) >> 4;
    byte sum = srec.length;
    int  mem_bytes = 0;

    if (!srec.byte_count)
      return;

    // validate checksum
    for (int i = 0; i < srec.byte_count; i++)
      sum += srec.data[i];

    sum++;  // zero means correct

    for (int i = 0; i < srec_address_byte_count(record_type); i++)
      addr[i*8 +: 8] = srec.data[srec_address_byte_count(record_type)-1-i];

    // copy data part over
    for (int i = srec_address_byte_count(record_type); i < srec.byte_count; i++)
      srec.mem[i-srec_address_byte_count(record_type)] = srec.data[i];

    // bytes minus address minus checksum
    mem_bytes = srec.byte_count - srec_address_byte_count(record_type) - 1;

    record.rtype    = srec_record_number_e'(record_type);
    record.addr     = addr;
    record.mem      = srec.mem;
    record.length   = mem_bytes > 0 ? mem_bytes : 0;
    record.checksum = sum;
    if (!$test$plusargs("srec_ignore_checksum") && record.checksum != 0)
      $fatal(1, "srec_end_read: invalid checksum %d for record %d", sum, record.rtype);
    srec.flags      = 0;
    srec.length     = 0;
    srec.byte_count = 0;
  endtask // srec_end_read

  task automatic srec_debug(ref srec_state_t srec, input byte record_type,
    input logic [31:0] address, byte mem[SREC_LINE_MAX_BYTE_COUNT + 1],
    input int          length, input int checksum_error);
    $display("S%d", record_type);
    $display("address=%x", address);
    $display("data bytes len=", length);
    $write("data bytes= ");
    for (int i = 0; i < length; i++)
      $write("%x", mem[i]);
    $write("\n");
    $display("checksum error=", checksum_error);
    if (checksum_error != 0)
      $fatal(1, "checksum error");
  endtask // srec_data_read

  // Is the S-Record type a header record?
  function byte srec_is_header(input byte rnum);
    srec_is_header = (!(rnum));
  endfunction // srec_is_header

  // Is the S-Record type a payload data record?
  function byte srec_is_data(input byte rnum);
    srec_is_data = ((rnum) && ((rnum) <= 3));
  endfunction // srec_is_data

  // Is the S-Record type a termination + start address record?
  function byte srec_is_termination(input byte rnum);
    srec_is_termination = ((rnum) >= 7);
  endfunction // srec_is_termination

  // Is the S-Record type a record count record?
  function byte srec_is_count(input byte rnum);
    srec_is_count = (((rnum) == 5) || ((rnum) == 6));
  endfunction // srec_is_count

  // Number of address bytes in a given S-Record type (2-4 for 16-32-bit)
  // (the obfuscated magic formula works for all valid record numbers: 0-3, 5-9)
  function byte srec_address_byte_count(input byte rnum);
    srec_address_byte_count = (2 + ((((rnum) & 1) || !(rnum)) ? ((rnum) & 2) : 1));
  endfunction // srec_address_byte_count

  task automatic srec_records_to_stimuli(input srec_record_t records[$],
    output logic [95:0] stimuli[$], output logic [31:0] entrypoint);

    logic [31:0] baseaddr;
    logic [31:0] addrcnt;
    logic [95:0] tmp;
    logic [63:0] datum;
    int j    = 0;
    int k    = 0;

    baseaddr = 0;
    addrcnt  = 0;
    datum    = 'x;

    for (int i = 0 ; i < records.size; i++) begin
      if (records[i].rtype == SREC_HEADER) begin
        // ignoring header
      end else if (records[i].rtype == SREC_DATA_32BIT) begin
        baseaddr = records[i].addr;
        if (addrcnt > {baseaddr[31:3], 3'b111} || addrcnt < {baseaddr[31:3], 3'b000}) begin
          // we don't need this tmp value anymore
          if (k == 0 && stimuli.size() > 0) begin
            tmp = stimuli.pop_back();
            datum = tmp[63:0];
          end
          // start with fresh datum
          datum = 'x;
        end else begin
          // retrieve old value and continue
          tmp = stimuli.pop_back();
          datum = tmp[63:0];
        end
        addrcnt  = baseaddr;
        k = baseaddr[2:0];
        baseaddr[2:0] = 3'b0;

        while (j < records[i].length || k < 64 / 8) begin
          datum[k*8 +: 8] = records[i].mem[j];
          j++;
          k++;
          addrcnt++;

          if (k == 64/8) begin
            stimuli.push_back({baseaddr, datum});
            k = 0;
            datum = 'x;
            baseaddr = addrcnt;
          end

          if (j == records[i].length) begin
            j = 0;
            break;
          end
        end

        // flush remaining datum
        stimuli.push_back({baseaddr, datum});

      end else if (records[i].rtype == SREC_DATA_16BIT) begin
        $fatal(1, "srec_records_to_stimuli: SREC_DATA_16BIT not implemented");
      end else if (records[i].rtype == SREC_DATA_24BIT) begin
        $fatal(1, "srec_records_to_stimuli: SREC_DATA_24BIT not implemented");
      end else if (records[i].rtype == SREC_COUNT_16BIT) begin
        $error(1, "srec_records_to_stimuli: SREC_COUNT_16BIT not implemented");
      end else if (records[i].rtype == SREC_COUNT_24BIT) begin
        $error(1, "srec_records_to_stimuli: SREC_COUNT_24BIT not implemented");
      end else if (records[i].rtype == SREC_TERMINATION_16BIT) begin
        entrypoint = records[i].addr;
      end else if (records[i].rtype == SREC_TERMINATION_24BIT) begin
        entrypoint = records[i].addr;
      end else if (records[i].rtype == SREC_TERMINATION_32BIT) begin
        entrypoint = records[i].addr;
      end else begin
        $info("ignoring rtype %d", records[i].rtype);
      end
    end

    // we pushed something too much
    if (k == 0) begin
      tmp = stimuli.pop_back();
      datum = tmp[63:0];
    end

  endtask // srec_records_to_stimuli

endpackage // srec_pkg

