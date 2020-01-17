SECTIONS
{
    .sgx.bin : {
        __sgx_start = .;
        *(.sgx.bin)
        __sgx_end = .;
    }
    . = . + 0x0000000;
    .sgx.code ALIGN(0x100000): {
        __sgx_code = .;
        *(.sgx.code)
        __sgx_code_end = .;
    }
    .sgx.pathOram ALIGN(0x100000):{
         __sgx_code_pathOram = .;
        *(.sgx.pathOram)
         __sgx_code_pathOram_end = .;
    }
    .sgx.pathOramData ALIGN(0x100000):{
         __sgx_data_pathOram = .;
        *(.sgx.pathOramData)
         __sgx_data_pathOram_end = .;

    }
    .sgx.pathOramBigData ALIGN(0x100000):{
         __sgx_data_big_pathOram = .;
        *(.sgx.pathOramBigData)
         __sgx_data_big_pathOram_end = .;

    }
}
__elf_end = .;
