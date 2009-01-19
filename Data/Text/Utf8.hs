{-# LANGUAGE MagicHash #-}
module Data.Text.Utf8 where

import Data.Char(ord)
import Data.Bits

import GHC.Exts
import GHC.Prim
import GHC.Word

between       :: Word8 -> Word8 -> Word8 -> Bool
between x y z = x >= y && x <= z
{-# INLINE between #-}

ord2   :: Char -> (Word8,Word8)
ord2 c = (x1,x2)
    where
      n  = ord c
      x1 = fromIntegral $ (shiftR n 6) + (0xC0 :: Int) :: Word8
      x2 = fromIntegral $ (n .&. 0x3F) + (0x80 :: Int) :: Word8

ord3   :: Char -> (Word8,Word8,Word8)
ord3 c = (x1,x2,x3)
    where
      n  = ord c
      x1 = fromIntegral $ (shiftR n 12) + (0xE0::Int) :: Word8
      x2 = fromIntegral $ ((shiftR n 6) .&. (0x3F::Int)) + (0x80::Int) :: Word8
      x3 = fromIntegral $ (n .&. (0x3F::Int)) + (0x80::Int) :: Word8

ord4   :: Char -> (Word8,Word8,Word8,Word8)
ord4 c = (x1,x2,x3,x4)
    where
      n  = ord c
      x1 = fromIntegral $ (shiftR n 18) + (0xF0::Int) :: Word8
      x2 = fromIntegral $ ((shiftR n 12) .&. (0x3F::Int)) + (0x80::Int) :: Word8
      x3 = fromIntegral $ ((shiftR n 6) .&. (0x3F::Int)) + (0x80::Int) :: Word8
      x4 = fromIntegral $ (n .&. (0x3F::Int)) + (0x80::Int) :: Word8

chr2       :: Word8 -> Word8 -> Char
chr2 (W8# x1#) (W8# x2#) = C# (chr# (z1# +# z2#))
    where
      y1# = word2Int# x1#
      y2# = word2Int# x2#
      z1# = uncheckedIShiftL# (y1# -# 0xC0#) 6#
      z2# = y2# -# 0x8F#
{-# INLINE chr2 #-}

chr3          :: Word8 -> Word8 -> Word8 -> Char
chr3 (W8# x1#) (W8# x2#) (W8# x3#) = C# (chr# (z1# +# z2# +# z3#))
    where
      y1# = word2Int# x1#
      y2# = word2Int# x2#
      y3# = word2Int# x3#
      z1# = uncheckedIShiftL# (y1# -# 0xE0#) 12#
      z2# = uncheckedIShiftL# (y2# -# 0x80#) 6#
      z3# = y3# -# 0x80#
{-# INLINE chr3 #-}

chr4             :: Word8 -> Word8 -> Word8 -> Word8 -> Char
chr4 (W8# x1#) (W8# x2#) (W8# x3#) (W8# x4#) =
    C# (chr# (z1# +# z2# +# z3# +# z4#))
    where
      y1# = word2Int# x1#
      y2# = word2Int# x2#
      y3# = word2Int# x3#
      y4# = word2Int# x4#
      z1# = uncheckedIShiftL# (y1# -# 0xF0#) 18#
      z2# = uncheckedIShiftL# (y2# -# 0x80#) 12#
      z3# = uncheckedIShiftL# (y3# -# 0x80#) 6#
      z4# = y4# -# 0x80#
{-# INLINE chr4 #-}

validate1    :: Word8 -> Bool
validate1 x1 = between x1 0x00 0x7F
{-# INLINE validate1 #-}

validate2       :: Word8 -> Word8 -> Bool
validate2 x1 x2 = between x1 0xC2 0xDF && between x2 0x80 0xBF
{-# INLINE validate2 #-}

validate3          :: Word8 -> Word8 -> Word8 -> Bool
validate3 x1 x2 x3 = validate3_1 x1 x2 x3 ||
                     validate3_2 x1 x2 x3 ||
                     validate3_3 x1 x2 x3 ||
                     validate3_4 x1 x2 x3
{-# INLINE validate3 #-}

validate4             :: Word8 -> Word8 -> Word8 -> Word8 -> Bool
validate4 x1 x2 x3 x4 = validate4_1 x1 x2 x3 x4 ||
                        validate4_2 x1 x2 x3 x4 ||
                        validate4_3 x1 x2 x3 x4
{-# INLINE validate4 #-}



validate3_1 x1 x2 x3 = (x1 == 0xE0) &&
                       between x2 0xA0 0xBF &&
                       between x3 0x80 0xBF
{-# INLINE validate3_1 #-}

validate3_2 x1 x2 x3 = between x1 0xE1 0xEC &&
                       between x2 0x80 0xBF &&
                       between x3 0x80 0xBF
{-# INLINE validate3_2 #-}

validate3_3 x1 x2 x3 = x1 == 0xED &&
                       between x2 0x80 0x9F &&
                       between x3 0x80 0xBF
{-# INLINE validate3_3 #-}

validate3_4 x1 x2 x3 = between x1 0xEE 0xEF &&
                       between x2 0x80 0xBF &&
                       between x2 0x80 0xBF
{-# INLINE validate3_4 #-}


validate4_1 x1 x2 x3 x4 = x1 == 0xF0 &&
                          between x2 0x90 0xBF &&
                          between x3 0x80 0xBF &&
                          between x4 0x80 0xBF
{-# INLINE validate4_1 #-}

validate4_2 x1 x2 x3 x4 = between x1 0xF1 0xF3 &&
                          between x2 0x80 0xBF &&
                          between x3 0x80 0xBF &&
                          between x4 0x80 0xBF
{-# INLINE validate4_2 #-}

validate4_3 x1 x2 x3 x4 = x1 == 0xF4 &&
                          between x2 0x80 0x8F &&
                          between x3 0x80 0xBF &&
                          between x4 0x80 0xBF
{-# INLINE validate4_3 #-}