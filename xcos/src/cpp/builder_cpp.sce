// This file is released under the 3-clause BSD license. See COPYING-BSD.

// This macro compiles the files

function builder_cpp()
  src_cpp_path = get_absolute_file_path("builder_cpp.sce");
  support_path = src_cpp_path + "../../support/";
  support_lib = support_path + "/bin/libsupport";

  CFLAGS = ilib_include_flag(src_cpp_path);
  CFLAGS = CFLAGS + " -I" + support_path + "/include";
  LDFLAGS = "";

  if (getos()<>"Windows") then
    if ~isdir(SCI+"/../../share") then
      // Source version
      CFLAGS = CFLAGS + " -I" + SCI + "/modules/scicos_blocks/includes" ;
      CFLAGS = CFLAGS + " -I" + SCI + "/modules/scicos/includes" ;
    else
      // Release version
      CFLAGS = CFLAGS + " -I" + SCI + "/../../include/scilab/scicos_blocks";
      CFLAGS = CFLAGS + " -I" + SCI + "/../../include/scilab/scicos";
    end
  else
    CFLAGS = CFLAGS + " -I" + SCI + "/modules/scicos_blocks/includes";
    CFLAGS = CFLAGS + " -I" + SCI + "/modules/scicos/includes";
    // Getting symbols
    if findmsvccompiler() <> "unknown" & haveacompiler() then
      LDFLAGS = LDFLAGS + " """ + SCI + "/bin/scicos.lib""";
      LDFLAGS = LDFLAGS + " """ + SCI + "/bin/scicos_f.lib""";
    end
  end

  //ilib_verbose(2);
  entry_points = [..
    "block_sum", ..
    "business_sum", ..
    "block_joystick", ..
    "block_mavlink", ..
    "block_osg", ..
    ];
   
  srcs =  [..
    "block_sum.c", ..
    "business_sum.c", ..
    "block_joystick.cpp", ..
    "block_mavlink.cpp", ..
    "block_osg.cpp", ..
    ];
  

  tbx_build_src(entry_points, srcs, ..
                "c",                                  ..
                src_cpp_path,                           ..
                [support_lib],                        ..
                LDFLAGS,                              ..
                CFLAGS,                               ..
                "",                           ..
                "",                                   ..
                "arktoolbox");
endfunction

builder_cpp();
clear builder_cpp; // remove builder_cpp on stack
