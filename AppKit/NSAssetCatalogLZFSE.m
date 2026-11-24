// LZFSE/LZVN decoder used by NSAssetCatalog. Darling's libcompression is a stub and the lzfse
// library in the tree is a host (Linux) build, so the decoder sources are compiled in directly.
#include "../../lzfse/src/lzfse_fse.c"
#include "../../lzfse/src/lzvn_decode_base.c"
#include "../../lzfse/src/lzfse_decode_base.c"
#include "../../lzfse/src/lzfse_decode.c"
