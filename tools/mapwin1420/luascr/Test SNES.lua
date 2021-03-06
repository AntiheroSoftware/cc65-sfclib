-- Export binary file
-- Thanks to Jerzy Kut for the num_to_char function

function num_to_char ( number )
 return ( string.char ( math.mod ( math.mod ( number, 256 ) + 256, 256 ) ) )
end

function writeIntForMap ( file, number )
 file:write ( num_to_char( number ))
 file:write ( num_to_char( number / 256 ))
end

function writeIntLSB ( file, number )
 file:write ( num_to_char( number )) -- x>>0
 file:write ( num_to_char( number / 256 )) -- x>>8
 file:write ( num_to_char( number / 65536 )) -- x>>16
 file:write ( num_to_char( number / 16777216 )) -- x>>24
end

-- CURBLOCK is selected block in 'still blocks'
-- getBlock(x,y) return offset in 'still blocks'
-- getBlockValue(Block, mappy.BLKBG) is graphic index
-- getPixel(x, y, G)

function main ()
 mappy.msgBox ("SNES Block Info", "Current block : "..mappy.getValue(mappy.CURBLOCK).." Block nuber : "..mappy.getValue(mappy.NUMBLOCKSTR), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
 mappy.msgBox ("SNES Block Info", "Current block : "..mappy.getBlockValue(4, mappy.BLKBG).." Block nuber : "..mappy.getBlock(6, 1), mappy.MMB_OKCANCEL, mappy.MMB_ICONQUESTION)
end

test, errormsg = pcall( main )
if not test then
    mappy.msgBox("Error ...", errormsg, mappy.MMB_OK, mappy.MMB_ICONEXCLAMATION)
end
