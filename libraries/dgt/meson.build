libdgt_includes = include_directories('include')

libdgt = library('dgt',
    nasm_args: asm_args,
    c_pch: nitro_pch,
    include_directories: [nitrosdk_includes, libdgt_includes],
    pic: false,
    sources: [
        'src/hash1.c',
        'src/hash2.c',
        'src/hmac.c',
        'asm/sha1-arm4cw.s',
        'asm/sha1s-arm4cw.s'
    ]
)

nitrosdk_libs += libdgt
