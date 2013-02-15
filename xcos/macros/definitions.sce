// This file is released under the 3-clause BSD license. See COPYING-BSD.

mode(-1);
lines(0);

_macroPath = pathconvert(get_absolute_file_path("definitions.sce"))
arktoolboxPath = strncpy(_macroPath, length(_macroPath)-length("/macros/"));
arktoolboxBlocks = ["TBX_SUM_c" "TBX_MUT_STYLE" "ARK_JOYSTICK" "ARK_MAVLINK", "ARK_OSG"];

clear _macroPath
