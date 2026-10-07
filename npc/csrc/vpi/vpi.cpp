#include <string.h>
#include <stdint.h>
#include <vpi_user.h>
#include "../minirv/pmem.h"

static PLI_INT32 pmem_read_calltf(PLI_BYTE8 *) {
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = vpi_iterate(vpiArgument, call);
    vpiHandle arg = vpi_scan(args);
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    int data = pmem_read(v.value.integer);
    vpi_free_object(args);
    v.value.integer = data;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 pmem_write_calltf(PLI_BYTE8 *) {
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = vpi_iterate(vpiArgument, call);
    s_vpi_value a, d , m;
    a.format = vpiIntVal;
    d.format = vpiIntVal;
    m.format = vpiIntVal;
    vpi_get_value(vpi_scan(args), &a);
    vpi_get_value(vpi_scan(args), &d);
    vpi_get_value(vpi_scan(args), &m);
    vpi_free_object(args);
    pmem_write(a.value.integer, d.value.integer, m.value.integer);
    return 0;
}


static PLI_INT32 load_program_calltf(PLI_BYTE8 *) {
    s_vpi_vlog_info info;
    vpi_get_vlog_info(&info);
    for (int i = 0; i < info.argc; i++) {
        if (strncmp(info.argv[i], "+img=", 5) == 0) {
        pmem_load(info.argv[i] + 5);
        return 0;
        }
    }
    vpi_printf("no program given: pass +img=<file.bin>\n");
    vpi_control(vpiFinish, 1);
    return 0;
}

static void register_tasks() {
    s_vpi_systf_data tf = {};
    tf.type = vpiSysFunc;
    tf.sysfunctype = vpiIntFunc;
    tf.tfname = (PLI_BYTE8 *)"$pmem_read";
    tf.calltf = pmem_read_calltf;
    vpi_register_systf(&tf);
    tf = {};
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$pmem_write";
    tf.calltf = pmem_write_calltf;
    vpi_register_systf(&tf);
    tf = {};
    tf.type = vpiSysTask;
    tf.tfname = (PLI_BYTE8 *)"$load_program";
    tf.calltf = load_program_calltf;
    vpi_register_systf(&tf);
}

extern "C" {
void (*vlog_startup_routines[])(void) = { register_tasks, 0 };
}