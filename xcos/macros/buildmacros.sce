// This file is released under the 3-clause BSD license. See COPYING-BSD.

function buildmacros()
  macros_path = get_absolute_file_path("buildmacros.sce");
  tbx_build_macros(TOOLBOX_NAME, macros_path);
  exec(pathconvert(macros_path+"/load_defs.sce", %f));
  tbx_build_blocks(toolbox_dir, blocks);
  exec(pathconvert(macros_path+"/unload_defs.sce", %f));
endfunction

buildmacros();
clear buildmacros; // remove buildmacros on stack

