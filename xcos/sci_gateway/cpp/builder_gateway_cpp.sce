// This file is released under the 3-clause BSD license. See COPYING-BSD.

function builder_gw_cpp()

  includes_src_cpp = ilib_include_flag(get_absolute_file_path("builder_gateway_cpp.sce") + "../../src/cpp");

  tbx_build_gateway("arktoolbox_cpp",                        ..
                    ["tbx_sum", "sci_tbx_sum"],                         ..
                    ["sci_tbx_sum.c"],                                  ..
                    get_absolute_file_path("builder_gateway_cpp.sce"),  ..
                    ["../../src/cpp/libxcos_tbx_skel",                  ..
                     "../../support/bin/libsupport"],                   ..
                    "",                                                 ..
                    includes_src_cpp);

endfunction

builder_gw_cpp();
clear builder_gw_cpp; // remove builder_gw_c on stack
