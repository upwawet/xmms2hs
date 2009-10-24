-- -*-haskell-*-
--  XMMS2 client library.
--
--  Author:  Oleg Belozeorov
--  Created: 5 Oct. 2009
--
--  Copyright (C) 2009 Oleg Belozeorov
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 3 of the License, or (at your option) any later version.
--
--  This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Lesser General Public License for more details.
--

module XMMS2.Client.ValueBase
  ( ValueType (..)
  , ValuePtr
  , Value
  , withValue
  , takeValue
  , getType
  , Mutable
  , Immutable
  , ValueClass (..)
  ) where

#include <xmmsclient/xmmsclient.h>

{# context prefix = "xmmsv" #}         

import Control.Monad
import Control.Monad.Trans
import Control.Monad.Exception  
import Data.Maybe
import XMMS2.Utils  

data Mutable
data Immutable

  
data T = T
{# pointer *t as ValuePtr -> T #}
data Value b = forall a. Value (Maybe a) (ForeignPtr T)

withValue (Value _ p) = withForeignPtr p

takeValue o p = do
  f <- maybe (newForeignPtr unref p) (\_ -> newForeignPtr_ p) o
  return $ Value o f
foreign import ccall unsafe "&xmmsv_unref"
  unref :: FunPtr (ValuePtr -> IO ())


{# enum type_t as ValueType
 { underscoreToCase }
 deriving (Show) #}


{# fun get_type as ^
 { withValue* `Value a'
 } -> `ValueType' cToEnum #}
               

class ValueClass b t where
  valueGet :: (MonadIO m, MonadException m) => Value b -> m t
                 

instance ValueClass a (Value a) where
  valueGet = return

