#include <stdio.h>
#include "remote_bitbang.h"

int main()
{
    unsigned char jtag_TCK, jtag_TMS, jtag_TDI, jtag_TRSTn;
    unsigned char jtag_TDO = 0;

    printf("calling rbs_init\n");
    int v = rbs_init(0);

    printf("tick 1\n");
    rbs_tick(&jtag_TCK, &jtag_TMS, &jtag_TDI, &jtag_TRSTn, jtag_TDO);
    printf("jtag exit is %d\n", rbs_done());
    return 0;
}
