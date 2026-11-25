libirc = library('irc',
    c_pch: nitro_pch,
    include_directories: nitrosdk_includes,
    pic: false,
    sources: files(
        'src/irc.c'
    )
)

nitrosdk_libs += libirc
